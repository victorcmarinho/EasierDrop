import 'dart:async' as i5;
import 'dart:ui' as i6;

import 'package:easier_drop/model/file_reference.dart' as i3;
import 'package:easier_drop/providers/files_provider.dart' as i2;
import 'package:mockito/mockito.dart' as i1;
import 'package:share_plus/share_plus.dart' as i4;

class _FakeObject_0 extends i1.SmartFake implements Object {
  _FakeObject_0(super.parent, super.parentInvocation);
}

class MockFilesProvider extends i1.Mock implements i2.FilesProvider {
  @override
  bool get recentlyAtLimit =>
      (super.noSuchMethod(
            Invocation.getter(#recentlyAtLimit),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  List<i3.FileReference> get files =>
      (super.noSuchMethod(
            Invocation.getter(#files),
            returnValue: <i3.FileReference>[],
            returnValueForMissingStub: <i3.FileReference>[],
          )
          as List<i3.FileReference>);

  @override
  List<i4.XFile> get xfiles =>
      (super.noSuchMethod(
            Invocation.getter(#xfiles),
            returnValue: <i4.XFile>[],
            returnValueForMissingStub: <i4.XFile>[],
          )
          as List<i4.XFile>);

  @override
  bool get isEmpty =>
      (super.noSuchMethod(
            Invocation.getter(#isEmpty),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  bool get hasFiles =>
      (super.noSuchMethod(
            Invocation.getter(#hasFiles),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  bool get hasListeners =>
      (super.noSuchMethod(
            Invocation.getter(#hasListeners),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  i5.Future<void> addFile(i3.FileReference? file) =>
      (super.noSuchMethod(
            Invocation.method(#addFile, [file]),
            returnValue: i5.Future<void>.value(),
            returnValueForMissingStub: i5.Future<void>.value(),
          )
          as i5.Future<void>);

  @override
  i5.Future<void> addFiles(Iterable<i3.FileReference>? files) =>
      (super.noSuchMethod(
            Invocation.method(#addFiles, [files]),
            returnValue: i5.Future<void>.value(),
            returnValueForMissingStub: i5.Future<void>.value(),
          )
          as i5.Future<void>);

  @override
  i5.Future<void> removeFile(i3.FileReference? file) =>
      (super.noSuchMethod(
            Invocation.method(#removeFile, [file]),
            returnValue: i5.Future<void>.value(),
            returnValueForMissingStub: i5.Future<void>.value(),
          )
          as i5.Future<void>);

  @override
  void removeByPath(String? pathname) => super.noSuchMethod(
    Invocation.method(#removeByPath, [pathname]),
    returnValueForMissingStub: null,
  );

  @override
  void clear() => super.noSuchMethod(
    Invocation.method(#clear, []),
    returnValueForMissingStub: null,
  );

  @override
  i5.Future<Object> shared({i6.Offset? position}) =>
      (super.noSuchMethod(
            Invocation.method(#shared, [], {#position: position}),
            returnValue: i5.Future<Object>.value(
              _FakeObject_0(
                this,
                Invocation.method(#shared, [], {#position: position}),
              ),
            ),
            returnValueForMissingStub: i5.Future<Object>.value(
              _FakeObject_0(
                this,
                Invocation.method(#shared, [], {#position: position}),
              ),
            ),
          )
          as i5.Future<Object>);

  @override
  void rescanNow() => super.noSuchMethod(
    Invocation.method(#rescanNow, []),
    returnValueForMissingStub: null,
  );

  @override
  void addFileForTest(i3.FileReference? ref) => super.noSuchMethod(
    Invocation.method(#addFileForTest, [ref]),
    returnValueForMissingStub: null,
  );

  @override
  void addListener(i6.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(i6.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void notifyListeners() => super.noSuchMethod(
    Invocation.method(#notifyListeners, []),
    returnValueForMissingStub: null,
  );
}
