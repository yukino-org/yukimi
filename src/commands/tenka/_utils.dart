import 'package:tenka/tenka.dart';
import 'package:utilx/utils.dart';
import '../../core/tenka.dart';
import '../../utils/console.dart';

String dyeTenkaMetadata(final TenkaMetadata metadata) =>
    '${Dye.dye(metadata.name, TenkaManager.repository.isInstalled(metadata) ? 'lightGreen' : 'cyan')} ${Dye.dye('[${StringUtils.capitalize(metadata.type.name)}/${metadata.author}/v${metadata.version}]', 'darkGray')}';
