import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';

class IntroductionScreen extends StatelessWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            //SECTION 1: Header (background + overlay + content)
            Container(
              //fill entire screen height
              height: size.height,
              width: double.infinity,
              child: Stack(
                children: [
                  //background image
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/bgImage.webp'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  //dark overlay
                  Container(color: Colors.black54),

                  //header + Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 40.0,
                    ),
                    child: Column(
                      children: [
                        //top row: logo + "TIPS"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/logo.png',
                              width: 80,
                            ),
                            NavItem(
                              text: 'TIPS',
                              onTap: () {
                                launchUrl(Uri.parse(
                                  'https://www.cisa.gov/secure-our-world/use-strong-passwords',
                                ));
                              },
                            ),
                          ],
                        ),
                        //abit of space after top row
                        const SizedBox(height: 50),

                        //Title, text app, n button.
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'PassGuard',
                                style: TextStyle(
                                  fontFamily: 'Montserrat Alternates',
                                  fontSize: 70,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 257),
                              const Text(
                                '#1 Secure Password Manager\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            //  const SizedBox(height: 1), //initial 20 size ---> changed size - overflow issue fixed 
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen(),
                                    ),
                                  );
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all<Color>(
                                    Colors.lightBlueAccent,
                                  ),
                                  foregroundColor: WidgetStateProperty.all<Color>(
                                    Colors.black,
                                  ),
                                  side: WidgetStateProperty.all<BorderSide>(
                                    const BorderSide(
                                      color: Color.fromARGB(222, 19, 162, 238),
                                      width: 1,
                                    ),
                                  ),
                                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                                    const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 30,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Log In / Sign Up',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //SECTION 2: How It Works
            Container(
              width: double.infinity,
              color: Colors.blueGrey[900],
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              child: Column(
                children: [
                  const Text(
                    'How It Works',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'using PassGuard is as easy as 1-2-3!',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      StepCard(
                        imageUrl: 'assets/add_user.png',
                        title: 'Create Account',
                        onTap: () {},
                      ),
                      StepCard(
                        imageUrl: 'assets/managerPass.png',
                        title: 'Generate & Store',
                        onTap: () {},
                      ),
                      StepCard(
                        imageUrl: 'assets/alert.png',
                        title: 'Receive Alerts',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //SECTION 3: Our Mission
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/vide1.gif'),
                 //fit: BoxFit.cover, // ensure it stretches
                ),
              ),
              child: Container(
                //black overlay
                width: double.infinity,
                color: Colors.black54,
                //reduce horizontal padding to remove left/right blank space
                padding: const EdgeInsets.symmetric(vertical: 250, horizontal: 20),
                child: const Column(
                  children: [
                    Text(
                      'Our Mission',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'PassGuard is committed to helping users protect their online identities with secure, '
                      'AI-generated passwords, encrypted vaults, and real-time breach alerts.\n\n'
                      'Our mission is to empower people with a simple, user-friendly solution that takes the guesswork '
                      'out of cybersecurity—ensuring every digital account remains safe and private',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),

            //SECTION 4: Footer
            Container(
              width: double.infinity,
              color: Colors.blueGrey[900],
              //horizontal padding so it spans full width
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PassGuard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Since 2025',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Chico, CA',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//NavItem widget (unchanged, except text color is white)
class NavItem extends StatelessWidget {
  final String text;
  final Function onTap;

  const NavItem({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

//StepCard widget (unchanged)
class StepCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final Function onTap;

  const StepCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widthFactor = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () => onTap(),
      child: Container(
        width: widthFactor * 0.3,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            //adds a slight shadow
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              imageUrl,
              width: 80,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}













