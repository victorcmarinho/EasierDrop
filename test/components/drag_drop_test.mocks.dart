import 'dart:async' as i6;
import 'dart:ui' as i7;

import 'package:easier_drop/controllers/drag_coordinator.dart' as i8;
import 'package:easier_drop/model/file_reference.dart' as i4;
import 'package:easier_drop/providers/files_provider.dart' as i3;
import 'package:flutter/widgets.dart' as i2;
import 'package:mockito/mockito.dart' as i1;
import 'package:share_plus/share_plus.dart' as i5;

class FakeObject0 extends i1.SmartFake implements Object {
  FakeObject0(super.parent, super.parentInvocation);
}

class FakeBuildContext1 extends i1.SmartFake implements i2.BuildContext {
  FakeBuildContext1(super.parent, super.parentInvocation);
}

class FakeValueNotifier2<T> extends i1.SmartFake
    implements i2.ValueNotifier<T> {
  FakeValueNotifier2(super.parent, super.parentInvocation);
}

class MockFilesProvider extends i1.Mock implements i3.FilesProvider {
  @override
  bool get recentlyAtLimit =>
      (super.noSuchMethod(
            Invocation.getter(#recentlyAtLimit),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  List<i4.FileReference> get files =>
      (super.noSuchMethod(
            Invocation.getter(#files),
            returnValue: <i4.FileReference>[],
            returnValueForMissingStub: <i4.FileReference>[],
          )
          as List<i4.FileReference>);

  @override
  List<i5.XFile> get validXFiles =>
      (super.noSuchMethod(
            Invocation.getter(#validXFiles),
            returnValue: <i5.XFile>[],
            returnValueForMissingStub: <i5.XFile>[],
          )
          as List<i5.XFile>);

  @override
  bool get hasFiles =>
      (super.noSuchMethod(
            Invocation.getter(#hasFiles),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  bool get isEmpty =>
      (super.noSuchMethod(
            Invocation.getter(#isEmpty),
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
  i6.Future<void> addFile(i4.FileReference? file) =>
      (super.noSuchMethod(
            Invocation.method(#addFile, [file]),
            returnValue: i6.Future<void>.value(),
            returnValueForMissingStub: i6.Future<void>.value(),
          )
          as i6.Future<void>);

  @override
  i6.Future<void> addFiles(Iterable<i4.FileReference>? files) =>
      (super.noSuchMethod(
            Invocation.method(#addFiles, [files]),
            returnValue: i6.Future<void>.value(),
            returnValueForMissingStub: i6.Future<void>.value(),
          )
          as i6.Future<void>);

  @override
  i6.Future<void> removeFile(i4.FileReference? file) =>
      (super.noSuchMethod(
            Invocation.method(#removeFile, [file]),
            returnValue: i6.Future<void>.value(),
            returnValueForMissingStub: i6.Future<void>.value(),
          )
          as i6.Future<void>);

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
  i6.Future<Object> shared({i7.Offset? position}) =>
      (super.noSuchMethod(
            Invocation.method(#shared, [], {#position: position}),
            returnValue: i6.Future<Object>.value(
              FakeObject0(
                this,
                Invocation.method(#shared, [], {#position: position}),
              ),
            ),
            returnValueForMissingStub: i6.Future<Object>.value(
              FakeObject0(
                this,
                Invocation.method(#shared, [], {#position: position}),
              ),
            ),
          )
          as i6.Future<Object>);

  @override
  void rescanNow() => super.noSuchMethod(
    Invocation.method(#rescanNow, []),
    returnValueForMissingStub: null,
  );

  @override
  void addFileForTest(i4.FileReference? ref) => super.noSuchMethod(
    Invocation.method(#addFileForTest, [ref]),
    returnValueForMissingStub: null,
  );

  @override
  void addListener(i7.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(i7.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void notifyListeners() => super.noSuchMethod(
    Invocation.method(#notifyListeners, []),
    returnValueForMissingStub: null,
  );
}

class MockDragCoordinator extends i1.Mock implements i8.DragCoordinator {
  @override
  i2.BuildContext get context =>
      (super.noSuchMethod(
            Invocation.getter(#context),
            returnValue: FakeBuildContext1(this, Invocation.getter(#context)),
            returnValueForMissingStub: FakeBuildContext1(
              this,
              Invocation.getter(#context),
            ),
          )
          as i2.BuildContext);

  @override
  i2.ValueNotifier<bool> get draggingOut =>
      (super.noSuchMethod(
            Invocation.getter(#draggingOut),
            returnValue: FakeValueNotifier2<bool>(
              this,
              Invocation.getter(#draggingOut),
            ),
            returnValueForMissingStub: FakeValueNotifier2<bool>(
              this,
              Invocation.getter(#draggingOut),
            ),
          )
          as i2.ValueNotifier<bool>);

  @override
  i2.ValueNotifier<bool> get hovering =>
      (super.noSuchMethod(
            Invocation.getter(#hovering),
            returnValue: FakeValueNotifier2<bool>(
              this,
              Invocation.getter(#hovering),
            ),
            returnValueForMissingStub: FakeValueNotifier2<bool>(
              this,
              Invocation.getter(#hovering),
            ),
          )
          as i2.ValueNotifier<bool>);

  @override
  i6.Future<void> init() =>
      (super.noSuchMethod(
            Invocation.method(#init, []),
            returnValue: i6.Future<void>.value(),
            returnValueForMissingStub: i6.Future<void>.value(),
          )
          as i6.Future<void>);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  void handleOutboundTest(dynamic raw) => super.noSuchMethod(
    Invocation.method(#handleOutboundTest, [raw]),
    returnValueForMissingStub: null,
  );

  @override
  i6.Future<void> beginExternalDrag() =>
      (super.noSuchMethod(
            Invocation.method(#beginExternalDrag, []),
            returnValue: i6.Future<void>.value(),
            returnValueForMissingStub: i6.Future<void>.value(),
          )
          as i6.Future<void>);

  @override
  void setHover(bool? value) => super.noSuchMethod(
    Invocation.method(#setHover, [value]),
    returnValueForMissingStub: null,
  );
}
