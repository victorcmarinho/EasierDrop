# Arquitetura Detalhada e Fluxos do Projeto

O Easier Drop utiliza uma arquitetura reativa e modular, otimizada para performance em ambiente desktop e web. Esta documentação detalha a interação entre os componentes e o ciclo de vida dos dados.

## 1. Visão de Camadas (Nível 2)
Uma visão mais profunda das responsabilidades de cada módulo.

```mermaid
graph TD
    subgraph UI_Layer ["Camada de Apresentação"]
        subgraph Views ["Telas"]
            MS["Main Screen (macOS)"]
            WS["Welcome/Intro"]
            SS["Settings Screen"]
            WWS["Web Home (Home Page)"]
        end
        subgraph Widgets ["Componentes Reutilizáveis"]
            DD["Drag & Drop Zone"]
            FS["Files Stack Visualizer"]
            TB["System Tray Menu"]
        end
    end

    subgraph Logic_Layer ["Camada de Negócio & Estado"]
        FP["FilesProvider (Shared State)"]
        SC["SettingsController (User Prefs)"]
        FP -- "Cache & Invalidação" --> FP
    end

    subgraph Service_Layer ["Módulos de Integração"]
        WMS["Window Manager (Multi-window)"]
        FDS["File Drop Service (Processing)"]
        FTS["Thumbnail Service (Isolate/Async)"]
        AS["Analytics (Aptabase)"]
    end

    subgraph System_Layer ["Infraestrutura Nativa"]
        macOS["macOS API (File System, Pasteboard)"]
        WebPlatform["Web (Assets, LocalStorage)"]
    end

    %% Fluxos de Dados
    Views --> FP
    Widgets --> FP
    FP --> FDS & FTS
    FDS --> macOS
    WMS --> macOS
    AS --> WebPlatform
```

## 2. Diagrama de Classes Detalhado
Foco nos principais atributos e métodos que orquestram a aplicação.

```mermaid
classDiagram
    class FilesProvider {
        -Map<String, FileReference> _files
        -List<FileReference> _cachedList
        +int maxFiles
        +addFiles(Iterable files)
        +removeFile(FileReference file)
        +clear()
        +shared(Offset position)
        +rescanNow()
    }

    class FileReference {
        +String pathname
        +String fileName
        +Uint8List thumbnail
        +bool isProcessing
        +withProcessing(bool value)
    }

    class WindowManagerService {
        <<Singleton>>
        +initialize()
        +openUpdateWindow()
        +createSecondaryWindow(String route)
        +setAlwaysOnTop(bool)
    }

    class FileRepository {
        +validateFile(String path)
        +readFileBytes(String path)
    }

    FilesProvider "1" --* "0..*" FileReference : gerencia
    FilesProvider ..> FileRepository : valida via
    FilesProvider ..> AnalyticsService : reporta a
    FileDropService ..> FilesProvider : alimenta
```

## 3. Fluxo de Vida do Arquivo (Sequence Diagram)
O caminho de um arquivo desde o "Drop" do usuário até o "Drag Out".

```mermaid
sequenceDiagram
    participant U as Usuário
    participant W as Widget (DragDrop)
    participant P as FilesProvider
    participant S as ThumbnailService
    participant AS as Analytics

    U->>W: Solta arquivo (Drop)
    W->>P: addFiles([file])
    activate P
    P->>P: Valida limite de arquivos
    P->>P: Registra em _files (isProcessing=true)
    P->>AS: fileAdded()
    P-->>W: Notifica UI (notifyListeners)
    
    par Thumbnail Generation
        P->>S: loadThumbnails(pathname)
        S->>S: Gera Bytes (Async)
        S-->>P: Retorna Thumbnail
        P->>P: Atualiza Referência
        P-->>W: Rebuild visual do arquivo
    end
    deactivate P

    U->>W: Arrasta para fora (Drag Out)
    W->>P: shared()
    P->>AS: fileShared()
```

## 4. Gestão de Janelas Secundárias
Como o app lida com múltiplas instâncias para transferência simultitânea.

```mermaid
graph LR
    subgraph MainApp ["Instância Principal"]
        M[Main Window] -- "WindowManager.create" --> W2
    end

    subgraph Window2 ["Janela Secundária"]
        W2[File Transfer Window] -- "Provider" --> FP2[FilesProvider Local]
    end

    W2 -- "Sincronização" --> EventSystem[Native Event System]
```

## 5. Estados da Coleção de Arquivos
O `FilesProvider` transita entre diferentes estados baseados na interação.

```mermaid
stateDiagram-v2
    [*] --> Vazio: App Inicia
    Vazio --> Adicionando: Evento de Drop
    Adicionando --> ComArquivos: Sucesso
    Adicionando --> LimiteAtingido: slots > maxFiles
    ComArquivos --> Adicionando: Novo Drop
    ComArquivos --> Removendo: Clique em 'X'
    Removendo --> ComArquivos: Itens restantes
    Removendo --> Vazio: Último item removido
    ComArquivos --> Vazio: Botão 'Clear All'
```

## Fluxo de Operação: "Drop & Drag"
1. **Captura**: O componente `DragDrop` intercepta o evento nativo do sistema operacional.
2. **Validação**: O `FileRepository` verifica se o arquivo ainda existe e se é acessível.
3. **Estado Reativo**: O `FilesProvider` gerencia um mapa único por caminho (pathname) para evitar duplicidade.
4. **Otimização**: Thumbnails são gerados sob demanda e cacheados em memória para garantir scroll fluido na stack de arquivos.
5. **Saída**: O envio (`Drag Out`) utiliza o protocolo nativo via `share_plus` ou APIs de drag nativas do macOS.
