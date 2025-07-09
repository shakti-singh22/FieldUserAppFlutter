import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes_fast.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';
Uint8List encryptAES(String plainText, Uint8List key, Uint8List iv) {
  final cipher = PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESFastEngine()));

  final keyParam = KeyParameter(key);
  final params = PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, CipherParameters?>(ParametersWithIV<KeyParameter>(keyParam, iv), null);

  cipher.init(true, params);

  final encoded = Uint8List.fromList(utf8.encode(plainText));
  final encrypted = cipher.process(encoded);

  return encrypted;
}

Uint8List decryptAES(Uint8List encryptedText, Uint8List key, Uint8List iv) {
  final cipher = PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESFastEngine()));

  final keyParam = KeyParameter(key);
  final params = PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, CipherParameters?>(ParametersWithIV<KeyParameter>(keyParam, iv), null);

  cipher.init(false, params);

  final decrypted = cipher.process(encryptedText);
  return decrypted;
}


