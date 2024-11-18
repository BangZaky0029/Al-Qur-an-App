import 'dart:io';
import 'package:alquran_app/screens/main_screen.dart/Kompas/compass_screen.dart';
import 'package:alquran_app/screens/main_screen.dart/MainHome/jadwalSholat.dart';
import 'package:alquran_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// class AppColors {
//   static const Color background = Color(0xFFE9F5DB);
//   static const Color cardBackground = Color(0xFFB5C99A);
//   static const Color textPrimary = Color(0xFF718355);
//   static const Color textSecondary = Color(0xFF87886A);
// }

// handle permission
Future<void> requestPermissions() async {
  var statusCamera = await Permission.camera.status;
  if (!statusCamera.isGranted) {
    await Permission.camera.request();
  }

  var statusStorage = await Permission.storage.status;
  if (!statusStorage.isGranted) {
    await Permission.storage.request();
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _selectedProfileImage;
  bool isDarkMode = false;
  bool isNotificationsOn = true;

  final List<String> _assetImages = [
    '/Users/rizkicahya/alquran_app/assets/profile/profile_dog.png',
    '/Users/rizkicahya/alquran_app/assets/profile/profile_cat.png',
    '/Users/rizkicahya/alquran_app/assets/profile/profile_goat.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      isNotificationsOn = prefs.getBool('isNotificationsOn') ?? true;
    });
  }

  Future<void> _editProfileField({
    required String title,
    required String initialValue,
    required Function(String) onSave,
  }) async {
    final TextEditingController controller =
        TextEditingController(text: initialValue);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter your $title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _selectedProfileImage = image.path;
      });
      // Lakukan pengunggahan ke server atau simpan lokal
      await Provider.of<AuthProvider>(context, listen: false)
          .updateProfilePicture(
              File(image.path), context); // Tambahkan context di sini
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedProfileImage = image.path;
        });

        // Lakukan pengunggahan ke server melalui AuthProvider
        bool success = await Provider.of<AuthProvider>(context, listen: false)
            .updateProfilePicture(File(image.path), context);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gambar profil berhasil diperbarui.")),
          );
          // Setelah unggah berhasil, reset _selectedProfileImage
          setState(() {
            _selectedProfileImage = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal mengunggah gambar.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tidak ada gambar yang dipilih.")),
        );
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengambil gambar.")),
      );
    }
  }

  void _showProfilePhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change Profile Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Upload Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose from Assets : ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  itemCount: _assetImages.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final assetImage = _assetImages[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedProfileImage = assetImage;
                        });
                        Navigator.pop(context);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          assetImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigasi berdasarkan index
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PrayerScheduleScreen()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CompassScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double heightPercentage = (100 / screenHeight);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.cardBackground,
                AppColors.textPrimary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Profile',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.cardBackground,
                    AppColors.textPrimary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _selectedProfileImage != null
                        ? FileImage(File(_selectedProfileImage!))
                        : (authProvider.profilePictureUrl != null
                                ? NetworkImage(authProvider.profilePictureUrl!)
                                : const NetworkImage(
                                    'https://via.placeholder.com/150'))
                            as ImageProvider,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authProvider.userName ?? 'Guest',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    authProvider.userEmail ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _showProfilePhotoOptions(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text(
                      'Change profile photo',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            // Profile Header Section

            // Settings Options Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  // Name - Edit name dialog
                  ListTile(
                    leading: const Icon(Icons.person_outline,
                        color: AppColors.textPrimary),
                    title: const Text(
                      'Name',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      _editProfileField(
                        title: 'Name',
                        initialValue: authProvider.userName ?? '',
                        onSave: (value) {
                          authProvider.setUserName(value);
                        },
                      );
                    },
                  ),
                  const Divider(),

                  // Phone - Edit phone dialog
                  ListTile(
                    leading: const Icon(Icons.phone_outlined,
                        color: AppColors.textPrimary),
                    title: const Text(
                      'Phone',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: Text(
                      authProvider.userPhoneNumber ?? '(480) 555-0103',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    onTap: () {
                      _editProfileField(
                        title: 'Phone Number',
                        initialValue: authProvider.userPhoneNumber ?? '',
                        onSave: (value) {
                          authProvider.setUserPhoneNumber(value);
                        },
                      );
                    },
                  ),
                  const Divider(),

                  // Email - Display email
                  ListTile(
                    leading: const Icon(Icons.email_outlined,
                        color: AppColors.textPrimary),
                    title: const Text(
                      'E-mail',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: Text(
                      authProvider.userEmail ?? 'example@example.com',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const Divider(),

                  // Change Password
                  ListTile(
                    leading: const Icon(Icons.lock_outline,
                        color: AppColors.textPrimary),
                    title: const Text(
                      'Change password',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      // Navigate to Change Password Screen
                    },
                  ),
                  const Divider(),
                  // Help
                  ListTile(
                    leading: const Icon(Icons.help_outline,
                        color: AppColors.textPrimary),
                    title: const Text(
                      'Help',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      // Navigate to Help Screen
                    },
                  ),
                  const Divider(),

                  // About
                  ListTile(
                    leading: const Icon(Icons.info_outline,
                        color: AppColors.textPrimary),
                    title: const Text(
                      'About',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      // Navigate to About Screen
                    },
                  ),
                  const Divider(),
                ],
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Log out'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            authProvider.logout();
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text('Log out'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Center(
                  child: Text(
                    'Log out',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text("Al-Quran - 1.0.0"),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: heightPercentage * screenHeight, // Tinggi Container
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.cardBackground,
              AppColors.textPrimary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(
                    top: 8), // Menyesuaikan posisi vertikal ikon
                child: Icon(Icons.home),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(
                    top: 8), // Menyesuaikan posisi vertikal ikon
                child: Icon(Icons.explore),
              ),
              label: 'Kompas',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(
                    top: 8), // Menyesuaikan posisi vertikal ikon
                child: Icon(Icons.person),
              ),
              label: 'Account',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.background,
          unselectedItemColor: AppColors.cardBackground,
          backgroundColor: AppColors.cardBackground.withOpacity(0.36),
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold, // Ketebalan teks ketika dipilih
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight:
                FontWeight.normal, // Ketebalan teks ketika tidak dipilih
          ),
        ),
      ),
    );
  }
}
