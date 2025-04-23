import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutDeveloperPage extends StatelessWidget {
  const AboutDeveloperPage({Key? key});

  Future<void> _launchURL(Uri uri) async {
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch $uri';
    }
  }

  void _showSocialMediaOptions(
      BuildContext context, Map<String, String> links) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height / 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Social Info',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 2,
                width: 80,
                color: Colors.blueGrey,
                margin: const EdgeInsets.symmetric(vertical: 10),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: links.entries.map((entry) {
                  final String platform = entry.key;
                  final String link = entry.value;
                  final IconData icon;
                  switch (platform) {
                    case 'Facebook':
                      icon = FontAwesomeIcons.facebook;
                      break;
                    case 'Twitter':
                      icon = FontAwesomeIcons.twitter;
                      break;
                    case 'Instagram':
                      icon = FontAwesomeIcons.instagram;
                      break;
                    case 'LinkedIn':
                      icon = FontAwesomeIcons.linkedin;
                      break;
                    default:
                      icon = FontAwesomeIcons.link;
                      break;
                  }
                  return Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          icon,
                          size: 40,
                        ),
                        onPressed: () {
                          launch((link));
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        platform,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeveloperCard(
      BuildContext context,
      String designation,
      String name,
      String department,
      String university,
      String imagePath,
      String userEmail,
      String userPhone,
      String userText,
      Map<String, String> socialMediaLinks,
      ) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(top: 16, left: 30, right: 30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: Colors.lightBlueAccent,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 5),
          Text(
            designation,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(7),
              topRight: Radius.circular(35),
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(7),
            ),
            child: Image.asset(
              imagePath,
              width: 100,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  department,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  university,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildContactIconButton(Icons.call, () {
                      _launchURL(Uri(scheme: 'tel', path: userPhone));
                    }),
                    const SizedBox(width: 15),
                    _buildContactIconButton(Icons.message, () {
                      _launchURL(Uri(scheme: 'sms', path: userText));
                    }),
                    const SizedBox(width: 15),
                    _buildContactIconButton(Icons.email, () {
                      _launchURL(Uri(
                        scheme: 'mailto',
                        path: userEmail,
                      ));
                    }),
                    const SizedBox(width: 15),
                    _buildMoreButton(() {
                      _showSocialMediaOptions(context, socialMediaLinks);
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactIconButton(IconData icon, VoidCallback onPressed) {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 35,
        width: 35,
        child: IconButton(
          icon: Icon(
            icon,
            color: Colors.white,
          ),
          onPressed: onPressed,
          iconSize: 20,
        ),
      ),
    );
  }

  Widget _buildMoreButton(VoidCallback onPressed) {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 35,
        width: 35,
        child: IconButton(
          icon: const Icon(
            Icons.more_horiz,
            color: Colors.white,
          ),
          onPressed: onPressed,
          iconSize: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(201, 215, 225, 1.0),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(34, 49, 63, 1),
        title: Text(
          'About Developers',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Text(
              'Team Tech Aid',
              style: TextStyle(
                color: Colors.teal,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black38,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 2,
              width: 80,
              color: Colors.teal,
            ),
            _buildDeveloperCard(
              context,
              'App Developer',
              'Habibur Rahman Khan Ratin',
              'B.Sc.(Engineering) in CSE',
              'Patuakhali Science and Technology University',
              'assets/images/ratin.jpg',
              'ratin16@cse.pstu.ac.bd',
              '01747697661',
              '01747697661',
              <String, String>{
                'Facebook':
                'https://www.facebook.com/ratin.khan.90?mibextid=aejMdD',
                'Twitter': '',
                'Instagram': '',
                'LinkedIn': '',
              },
            ),
            _buildDeveloperCard(
              context,
              'App Developer',
              'Md. Rad Shahmat',
              'B.Sc.(Engineering) in CSE',
              'Patuakhali Science and Technology University',
              'assets/images/rad.jpg',
              'rad16@cse.pstu.ac.bd',
              '01716040447',
              '01716040447',
              <String, String>{
                'Facebook': 'https://www.facebook.com/rad.shahmat.37',
                'Twitter': 'https://twitter.com/Rad_Shahmat',
                'Instagram':
                'https://instagram.com/rad.shahmat?utm_source=qr&igshid=YzU1NGVlODEzOA==',
                'LinkedIn': 'https://linkedin.com/in/rad-shahmat-8979a81a2',
              },
            ),
          ],
        ),
      ),
    );
  }
}
