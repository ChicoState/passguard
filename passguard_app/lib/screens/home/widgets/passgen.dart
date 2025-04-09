import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:word_generator/word_generator.dart';
import '../../passwordchecker.dart';

class PassGen extends StatefulWidget {
  const PassGen({Key? key}) : super(key: key);

  @override
  _PassGenState createState() => _PassGenState();
}

class _PassGenState extends State<PassGen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();

  bool _obscureText = true;
  bool _includeCapital = true;
  bool _includeNumber = true;
  bool _includeSpecial = true;
  bool _useWords = false;

  String _lengthError = '';
  bool _isCompromised = false;
  bool _isChecking = false;

  //WordGenerator from the word_generator package
  final WordGenerator wordGenerator = WordGenerator();

  @override
  void dispose() {
    _passwordController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  Future<void> _generatePassword() async {
    setState(() {
      _isChecking = true;
      _lengthError = '';
    });
    String newPassword = '';
    final int targetLength;
    if (_lengthController.text.isNotEmpty) {
      try {
        targetLength = int.parse(_lengthController.text);
        if (targetLength < 8 || targetLength > 32) {
          setState(() {
            _lengthError = 'Length must be between 8 and 32.';
            _isChecking = false;
          });
          return;
        }
      } catch (e) {
        setState(() {
          _lengthError = 'Please enter a valid integer for length.';
          _isChecking = false;
        });
        return;
      }
    } else {
      targetLength = Random().nextInt(32 - 8 + 1) + 8; // Default random password length between 8 and 32
    }

    if (_useWords) {
      bool meetsCriteria = false;
      String candidate = '';
      // Loop until candidate meets required length and includes required elements.
      while (!meetsCriteria) {
        int wordCount = Random().nextBool() ? 2 : 4;
        List<String> words = List.generate(wordCount, (_) => wordGenerator.randomNoun());
        if (_includeCapital) {
          int idx = Random().nextInt(words.length);
          words[idx] = words[idx][0].toUpperCase() + words[idx].substring(1);
        }
        // Build segments list to randomized element order
        String wordsBlock = words.join('');
        List<String> segments = [wordsBlock];
        if (_includeNumber) {
          segments.add(Random().nextInt(100).toString().padLeft(2, '0'));
        }
        if (_includeSpecial) {
          const specialChars = '!@#\$%^&*';
          segments.add(specialChars[Random().nextInt(specialChars.length)]);
        }
        segments.shuffle(Random());
        candidate = segments.join('');
        bool hasNumber = !_includeNumber || candidate.contains(RegExp(r'\d'));
        bool hasSpecial = !_includeSpecial || candidate.contains(RegExp(r'[!@#\$%^&*]'));
        if (candidate.length == targetLength && hasNumber && hasSpecial) {
          meetsCriteria = true;
        }
      }
      newPassword = candidate;
    } 
    else {
      // Ensure element requirements
      newPassword = _generateRandomPassword(targetLength, _includeCapital, _includeNumber, _includeSpecial);
    }

    // Checks generated password for leak with PasswordChecker
    bool compromised = false;
    try {
      compromised = await PasswordChecker.checkPasswordLeak(newPassword);
    } catch (e) {
      compromised = false;
    }

    setState(() {
      _passwordController.text = newPassword;
      _isCompromised = compromised;
      _isChecking = false;
    });
  }
  
  // Random password generator for non-useWords case.
  String _generateRandomPassword(int length, bool includeCapital, bool includeNumber, bool includeSpecial) {
    const lowerChars = 'abcdefghijklmnopqrstuvwxyz';
    const upperChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const specialChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    // Build base pool and a list to hold mandatory characters.
    String pool = lowerChars; // always include lowercase
    List<String> mandatory = [];

    if (includeCapital) {
      pool += upperChars;
      mandatory.add(upperChars[Random.secure().nextInt(upperChars.length)]);
    }
    if (includeNumber) {
      pool += numbers;
      mandatory.add(numbers[Random.secure().nextInt(numbers.length)]);
    }
    if (includeSpecial) {
      pool += specialChars;
      mandatory.add(specialChars[Random.secure().nextInt(specialChars.length)]);
    }
    
    // Calculate how many additional characters needed.
    int remainingLength = length - mandatory.length;
    List<String> passwordChars = List.from(mandatory);
    final rand = Random.secure();
    for (int i = 0; i < remainingLength; i++) {
      passwordChars.add(pool[rand.nextInt(pool.length)]);
    }
    
    // Shuffles elements in password and returns string
    passwordChars.shuffle(rand);
    return passwordChars.join();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row containing the password field, copy, generate button, and status indicator
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Generated Password',
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _passwordController.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password copied to clipboard')),
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: _isChecking ? null : _generatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DB8FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text(
                    "Generate",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ), 
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Tooltip(
                    message: _isCompromised ? 'Password compromised' : 'Password not compromised',
                    child: Icon(
                      Icons.circle,
                      color: _isCompromised ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            if (_lengthError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _lengthError,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 8),
            // ExpansionTile for additional options
            ExpansionTile(
              title: const Text('Options'),
              children: [
                Row(
                  children: [
                    const Text('Specific Length:'),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _lengthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '8 - 32',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _includeCapital,
                      onChanged: (val) {
                        setState(() {
                          _includeCapital = val ?? true;
                        });
                      },
                    ),
                    const Text('Include Capital Letters'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _includeNumber,
                      onChanged: (val) {
                        setState(() {
                          _includeNumber = val ?? true;
                        });
                      },
                    ),
                    const Text('Include Numbers'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _includeSpecial,
                      onChanged: (val) {
                        setState(() {
                          _includeSpecial = val ?? true;
                        });
                      },
                    ),
                    const Text('Include Special Characters'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _useWords,
                      onChanged: (val) {
                        setState(() {
                          _useWords = val ?? false;
                        });
                      },
                    ),
                    const Text('Use Random Words'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
