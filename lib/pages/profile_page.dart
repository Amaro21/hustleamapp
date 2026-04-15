import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/repositories/hustleam_repository.dart';
import 'package:hustleamapp/pages/admin_page.dart';
import '../logic/cart/cart_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _showPassModal(HustleamRepository repo) {
    final TextEditingController passController = TextEditingController();
    bool isVisible = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 25,
            right: 25,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Security Update",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Update your login credentials.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passController,
                obscureText: !isVisible,
                decoration: InputDecoration(
                  hintText: "New Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setModalState(() => isVisible = !isVisible),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF6F6F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              _actionBtn(
                label: "SAVE CHANGES",
                color: Colors.black,
                onTap: () async {
                  if (passController.text.length < 6) return;
                  await repo.updatePassword(passController.text.trim());
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Credentials Updated!")),
                    );
                  }
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddrModal(HustleamRepository repo, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) =>
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: repo.getUserData(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          final userData = snapshot.data!.data();
          final List<dynamic> addresses = userData?['savedAddresses'] ?? [];
          final String selected = userData?['selectedAddress'] ?? '';

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Addresses",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _showAddAddressDialog(repo, uid),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final addr = addresses[index].toString();
                      bool isSelected = addr == selected;
                      return Container(
                        margin: const EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.black
                                : Colors.grey.shade200,
                            width: 2,
                          ),
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFFBFBFC),
                        ),
                        child: ListTile(
                          onTap: () {
                            repo.selectAddress(uid, addr, isNew: false);
                            Navigator.pop(modalContext);
                          },
                          leading: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected
                                ? const Color(0xFF00B761)
                                : Colors.grey,
                          ),
                          title: Text(
                            addr,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => repo.deleteAddress(uid, addr),
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
      ),
    );
  }

  void _showHelpCenter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "HELP CENTER",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
            const Text(
              "FREQUENTLY ASKED QUESTIONS",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _faqItem(
                    "How long is shipping?",
                    "Standard shipping takes 3-5 business days within the Philippines. You will receive a tracking number once your order is processed.",
                  ),
                  _faqItem(
                    "Can I return or exchange items?",
                    "Yes, returns are accepted within 7 days of receipt for size exchanges or manufacturing defects, provided tags are still attached.",
                  ),
                  _faqItem(
                    "What is CVC Cotton 220 GSM?",
                    "Our fabrics are a premium blend of cotton and polyester, offering a heavy, high-quality feel that holds its shape and print perfectly.",
                  ),
                  _faqItem(
                    "How do I wash my Hustleam items?",
                    "To preserve the art, we recommend cold washing inside out and avoiding direct ironing on the printed areas.",
                  ),
                  _faqItem(
                    "Where are you located?",
                    "Hustleam is proudly based in the Philippines, delivering wearable art nationwide.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _actionBtn(
              label: "CLOSE",
              color: Colors.black,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.5,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Image.asset(
              'assets/images/HCC1.png',
              height: 80,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.shopping_bag, size: 80),
            ),
            const SizedBox(height: 20),
            const Text(
              "HUSTLEAM CLOTHING CO.",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            ),
            const Text(
              "EST. 2024",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Hustleam is more than a brand; it's a movement. We make wearable art designed by independent artists for the determined and the driven. Every piece tells a story of the hustle.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 25),
            const Divider(),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "CLOSE",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressDialog(HustleamRepository repo, String uid) {
    final TextEditingController addrController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("New Address"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: addrController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter full address"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final text = addrController.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(dialogContext);
                repo.selectAddress(uid, text, isNew: true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<HustleamRepository>();
    final user = repo.currentUser;

    if (user == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC), // Minimalist studio background
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: repo.getUserData(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          if (!snapshot.hasData || !snapshot.data!.exists)
            return _buildErrorState(repo);

          final data = snapshot.data!.data()!;
          final email = data['email'] ?? '';
          final username = data['username'] ?? 'User';
          final profileUrl = data['profileImageUrl'];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(25, 80, 25, 40),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(35),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: profileUrl != null
                            ? NetworkImage(profileUrl)
                            : null,
                        child: profileUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(25),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _sectionLabel("ACCOUNT SETTINGS"),
                    _buildMenuCard([
                      _item(
                        Icons.lock_outline,
                        "Security",
                        () => _showPassModal(repo),
                      ),
                      _item(
                        Icons.location_on_outlined,
                        "Shipping Addresses",
                        () => _showAddrModal(repo, user.uid),
                      ),
                      if (email == "amaro02@gmail.com")
                        _item(
                          Icons.admin_panel_settings_outlined,
                          "Admin Dashboard",
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminPage(),
                            ),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 25),
                    _sectionLabel("SUPPORT & INFO"),
                    _buildMenuCard([
                      _item(
                        Icons.help_outline,
                        "Help Center",
                        _showHelpCenter,
                      ),
                      _item(
                        Icons.info_outline,
                        "About Hustleam",
                        _showAbout,
                      ),
                    ]),
                    const SizedBox(height: 50),
                    _actionBtn(
                      label: "LOGOUT",
                      color: Colors.white,
                      textColor: Colors.red,
                      isOutlined: true,
                      borderColor: Colors.red,
                      onTap: () async {
                        context.read<CartBloc>().add(ClearCartEvent());

                        await context.read<HustleamRepository>().logout();
                      },
                    ),
                    const SizedBox(height: 50),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 5, bottom: 10),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Colors.grey,
            letterSpacing: 1.5,
          ),
        ),
      );

  Widget _buildMenuCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(children: children),
      );

  Widget _item(IconData icon, String title, VoidCallback tap) => ListTile(
        onTap: tap,
        leading: Icon(icon, color: Colors.black, size: 22),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      );

  Widget _actionBtn({
    required String label,
    required Color color,
    Color textColor = Colors.white,
    bool isOutlined = false,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isOutlined
                ? BorderSide(color: borderColor ?? Colors.black, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(HustleamRepository repo) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("User details missing."),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => repo.logout(),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
