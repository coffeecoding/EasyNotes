import 'package:easynotes/utils/crypto/rfc2898_helper.dart';

void main() async {
  String salt = 'EZok1rPCScDgPIryGGShXKCI6Rg=';
  String pw = 'a';

  String hash = await RFC2898Helper.computePasswordHash(pw, salt, 10000, 32);

  print('Password Hash:');
  print(hash);
}
