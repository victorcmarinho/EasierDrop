import 'dart:async' as _i6;
import 'dart:ui' as _i7;

import 'package:easier_drop/controllers/drag_coordinator.dart' as _i8;
import 'package:easier_drop/model/file_reference.dart' as _i4;
import 'package:easier_drop/providers/files_provider.dart' as _i3;
import 'package:flutter/widgets.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:share_plus/share_plus.dart' as _i5;

class _FakeObject_0 extends _i1.SmartFake implements Object {
  _FakeObject_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeBuildContext_1 extends _i1.SmartFake implements _i2.BuildContext {
  _FakeBuildContext_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeValueNotifier_2<T> extends _i1.SmartFake
    implements _i2.ValueNotifier<T> {
  _FakeValueNotifier_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class MockFilesProvider extends _i1.Mock implements _i3.FilesProvider {
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
  int get fileCount =>
      (super.noSuchMethod(
            Invocation.getter(#fileCount),
            returnValue: 0,
            returnValueForMissingStub: 0,
          )
          as int);

  @override
  bool get recentlyAtLimit =>
      (super.noSuchMethod(
            Invocation.getter(#recentlyAtLimit),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  List<_i4.FileReference> get files =>
      (super.noSuchMethod(
            Invocation.getter(#files),
            returnValue: <_i4.FileReference>[],
            returnValueForMissingStub: <_i4.FileReference>[],
          )
          as List<_i4.FileReference>);

  @override
  List<_i5.XFile> get validXFiles =>
      (super.noSuchMethod(
            Invocation.getter(#validXFiles),
            returnValue: <_i5.XFile>[],
            returnValueForMissingStub: <_i5.XFile>[],
          )
          as List<_i5.XFile>);

  @override
  bool get hasListeners =>
      (super.noSuchMethod(
            Invocation.getter(#hasListeners),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  _i6.Future<void> addFile(_i4.FileReference? file) =>
      (super.noSuchMethod(
            Invocation.method(#addFile, [file]),
            returnValue: _i6.Future<void>.value(),
            returnValueForMissingStub: _i6.Future<void>.value(),
          )
          as _i6.Future<void>);

  @override
  _i6.Future<void> addFiles(Iterable<_i4.FileReference>? files) =>
      (super.noSuchMethod(
            Invocation.method(#addFiles, [files]),
            returnValue: _i6.Future<void>.value(),
            returnValueForMissingStub: _i6.Future<void>.value(),
          )
          as _i6.Future<void>);

  @override
  _i6.Future<void> removeFile(_i4.FileReference? file) =>
      (super.noSuchMethod(
            Invocation.method(#removeFile, [file]),
            returnValue: _i6.Future<void>.value(),
            returnValueForMissingStub: _i6.Future<void>.value(),
          )
          as _i6.Future<void>);

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
  _i6.Future<Object> shared({_i7.Offset? position}) =>
      (super.noSuchMethod(
            Invocation.method(#shared, [], {#position: position}),
            returnValue: _i6.Future<Object>.value(
              _FakeObject_0(
                this,
                Invocation.method(#shared, [], {#position: position}),
              ),
            ),
            returnValueForMissingStub: _i6.Future<Object>.value(
              _FakeObject_0(
                this,
                Invocation.method(#shared, [], {#position: position}),
              ),
            ),
          )
          as _i6.Future<Object>);

  @override
  void rescanNow() => super.noSuchMethod(
    Invocation.method(#rescanNow, []),
    returnValueForMissingStub: null,
  );

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  void addFileForTest(_i4.FileReference? ref) => super.noSuchMethod(
    Invocation.method(#addFileForTest, [ref]),
    returnValueForMissingStub: null,
  );

  @override
  void addListener(_i7.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i7.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void notifyListeners() => super.noSuchMethod(
    Invocation.method(#notifyListeners, []),
    returnValueForMissingStub: null,
  );
}

class MockDragCoordinator extends _i1.Mock implements _i8.DragCoordinator {
  @override
  _i2.BuildContext get context =>
      (super.noSuchMethod(
            Invocation.getter(#context),
            returnValue: _FakeBuildContext_1(this, Invocation.getter(#context)),
            returnValueForMissingStub: _FakeBuildContext_1(
              this,
              Invocation.getter(#context),
            ),
          )
          as _i2.BuildContext);

  @override
  _i2.ValueNotifier<bool> get draggingOut =>
      (super.noSuchMethod(
            Invocation.getter(#draggingOut),
            returnValue: _FakeValueNotifier_2<bool>(
              this,
              Invocation.getter(#draggingOut),
            ),
            returnValueForMissingStub: _FakeValueNotifier_2<bool>(
              this,
              Invocation.getter(#draggingOut),
            ),
          )
          as _i2.ValueNotifier<bool>);

  @override
  _i2.ValueNotifier<bool> get hovering =>
      (super.noSuchMethod(
            Invocation.getter(#hovering),
            returnValue: _FakeValueNotifier_2<bool>(
              this,
              Invocation.getter(#hovering),
            ),
            returnValueForMissingStub: _FakeValueNotifier_2<bool>(
              this,
              Invocation.getter(#hovering),
            ),
          )
          as _i2.ValueNotifier<bool>);

  @override
  _i6.Future<void> init() =>
      (super.noSuchMethod(
            Invocation.method(#init, []),
            returnValue: _i6.Future<void>.value(),
            returnValueForMissingStub: _i6.Future<void>.value(),
          )
          as _i6.Future<void>);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  _i6.Future<void> beginExternalDrag() =>
      (super.noSuchMethod(
            Invocation.method(#beginExternalDrag, []),
            returnValue: _i6.Future<void>.value(),
            returnValueForMissingStub: _i6.Future<void>.value(),
          )
          as _i6.Future<void>);

  @override
  void setHover(bool? value) => super.noSuchMethod(
    Invocation.method(#setHover, [value]),
    returnValueForMissingStub: null,
  );

  @override
  void handleOutboundTest(dynamic raw) => super.noSuchMethod(
    Invocation.method(#handleOutboundTest, [raw]),
    returnValueForMissingStub: null,
  );
}
