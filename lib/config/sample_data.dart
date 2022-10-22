import 'package:easynotes/models/models.dart';
import 'package:easynotes/utils/crypto/algorithm_identifier.dart';

class SampleData {
  static final sampleUser = User.fromJson(
      '{"id":"asdf","email":"guest@mail.com","email_verified":false,"display_name":"Guest","created":1661422214,"pwsalt":"EZok1rPCScDgPIryGGShXKCI6Rg=","pwhash":"pmaUCRZMRHK89GsN7WaGcVUbxoQ/2twcU4TPk9voG+nTFlF56stIAsrlos6eDcI49BDI1FYDm+PGFnBlUd9SsA==","pubkey":"<RSAKeyValue><Modulus>0HIr7MT+6CdxhDwitYBBr4l0F7b+eWT4UnL3BWbcsksymhqeCu9WUOXGi8jAkZqAL0Ks4ZGvolXufX+KZF4dwYm9JtlOhvaE6bRzZa3djlJG5sqnWoVLoGLmjF9sZIGNgSM5KgIUdEm7/V/mdPU/PUGy1zzWtRKqLOBYGcMk2RPmkEU1e+CxuGhQmk2Zq6QGWhRDDyoxHzxxh0KKaEYT99Bo6BDYK69r3YcxyUYyZAPSgdx1Y33QiTjxQxhds44qr2TJ0QBxmS2DfYtWchqqFPU8uSn6sPYjam+fIgezgil+ixutHqc6YPItpLtmppqxHBjzpr2ZyMP2xwHa4YUDyQ==</Modulus><Exponent>AQAB</Exponent></RSAKeyValue>","privkey_crypt":"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","verifying_key":"<RSAKeyValue><Modulus>9YKZ9JiejcaPCg3m+jHLIoNazoyJLsc8Gi5y7b4baSA1mucwo1v6WJT5yyLqXzm7lV2qBktR9icjRyvLRKb8anx/UzwOwIVJdY1RWoAfqN8EGiYXM1pyVSl/CHtdhQ/rThQxg5iYasbYmU0Ugtuw618zse2Bp1xE9SGVHuCtBx3mrsBEiRRc10pjB0pB0CDyiXxnrEdOKAHSArzbqe5ArkSBDYCHAAmmARrInuFfedxFi87EgbJol7w8AYEoQSLjsfoKZ+DgLFeuWa/WMS2Gu3BBXIHGPgT+d6V9xPYOSWeCBUY8MG7ddPlus9ry0ofGRFI5MoEW1OBK3qXT3Rc2/Q==</Modulus><Exponent>AQAB</Exponent></RSAKeyValue>","signing_key_crypt":"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","algorithm_identifier": "{!name!:!PBES2!,!iterations!:10000,!saltLen!:20,!hashLen!:32,!rsaKeyLen!:2048,!dkLen!:32,!aesivLen!:16}"}');

  static List<Item> sampleItems = <Item>[
    Item.mock('1', null, "Projects", 0, '#F58C81'), // id 1
    Item.mock('2', '1', "World Conquest", 0), // id 2
    Item.mock('3', '1', "EasyNotes", 0), // id 3
    Item.mock('4', '1', "Slay Enemies", 0), // id 4
    Item.mock('5', '1', "Get Wifey", 0), // id 5
    Item.mock('6', null, "Software", 0, '#E09F47'), // id 6
    Item.mock('7', '6', "C# Notes", 0), // id 7
    Item.mock('8', '6', "Web Notes", 0), // id 8
    Item.mock('9', '8', "CSS Notes", 0), // id 9
    Item.mock('10', '8', "HTML Notes", 0), // id 10
    Item.mock('11', '6', "JavaScript", 0), // id 11
    Item.mock('12', null, "Uni", 0, '#A9B852'), // id 12
    Item.mock('13', '12', "Praktikum", 0), // id 13
    Item.mock('14', '12', "Seminar", 0), // id 14
    Item.mock('55', null, "Business", 0, '#54C794'), // id 55
    Item.mock('56', null, "Jobs", 0, '#00C4D7'), // id 56
    Item.mock('57', null, "Interesting", 0, '#6EB2FD'), // id 57
    Item.mock('58', null, "Home", 0, '#B69CF6'), // id 58
    Item.mock('59', null, "Finance", 0, '#E58CC5'), // id 59

    Item.mock('15', '1', "General Tips", 1),
    Item.mock('16', '3', "Brainstorming", 1),
    Item.mock('17', '2', "Resources", 1),
    Item.mock('18', '2', "The historically proven way", 1),
    Item.mock('19', '3', "MVP features", 1),
    Item.mock('20', '4', "Enemy 1", 1),
    Item.mock('21', '4', "Enemy 2", 1),
    Item.mock('22', '5', "The long, rocky path", 1),
    Item.mock('23', '6', "General Software Ideas", 1),
    Item.mock('24', '6', "A legendary article", 1),
    Item.mock('25', '7', "C# 9 - new Concepts", 1),
    Item.mock('26', '7', "WPF notes", 1),
    Item.mock('27', '8', "Web Dev in 2023", 1),
    Item.mock('28', '9', "FlexBox mastery", 1),
    Item.mock('29', '9', "CSS Tricks", 1),
    Item.mock('30', '10', "Build a website from scratch", 1),
    Item.mock('31', '10', "Rarely used HTML tags & elements", 1),
    Item.mock('32', '11', "Chris Hawkes JavaScript notes", 1),
    Item.mock('33', '12', "Aktuelles", 1),
    Item.mock('34', '12', "Fortschritt Studium", 1),
    Item.mock('35', '14', "Forschungsthemen", 1),
    Item.mock('36', '13', "Aktuelle Aufgaben", 1),
    Item.mock('37', '13', "Bericht Notizen", 1),
    Item.mock('38', '13', "Onboarding", 1),
    Item.mock('39', '14', "Brainstorming", 1),
    Item.mock('40', '14', "Organisatorisches", 1),

    // lots of notes inside software topic, for testing scrolling and all
    Item.mock('41', '6', "Another legendary article", 1),
    Item.mock('42', '6', "The legend continues ...", 1),
    Item.mock('43', '6', "Legend has it", 1),
    Item.mock('44', '6', "There are more legends", 1),
    Item.mock('45', '6', "more legend articles", 1),
    Item.mock('46', '6', "Neverending legends", 1),
    Item.mock('47', '6', "Legendary legendness", 1),
    Item.mock('48', '6', "Perpetual legenderainess", 1),
    Item.mock('49', '6', "Legendception", 1),
    Item.mock('50', '6', "Legionary?", 1),
    Item.mock('51', '6', "Legendary legions?", 1),
    Item.mock('52', '6', "The legion of legends", 1),
    Item.mock('53', '6', "A legion of legends", 1),
    Item.mock('54', '6', "Legends never die?", 1),
  ];
}
