export 'link_opener_interface.dart';

import 'link_opener_interface.dart';
import 'link_opener_stub.dart' if (dart.library.html) 'link_opener_web.dart'
    as impl;

LinkOpener createLinkOpener() => impl.createLinkOpener();
