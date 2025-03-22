import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../utils/color.dart';
import '../view_model.dart/banner_view_model.dart';

class BannerPage extends StatefulWidget {
  const BannerPage({super.key});

  @override
  State<BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  final TextEditingController _linkController = TextEditingController();
  bool _isActive = true;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<BannerViewModel>().init();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BannerViewModel>().init();
    });
  }

  @override
  void dispose() {
 _linkController.dispose(); 
    super.dispose();
  }

  Future<void> _selectImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _addBanner(BannerViewModel viewModel) async {
    if (_selectedImage == null || _linkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image and enter a link'),
        ),
      );
      return;
    }

    await viewModel.createBanner(
      imageFile: _selectedImage!,
      link: _linkController.text,
      isActive: _isActive,
    );

    setState(() {
      _linkController.clear();
      _selectedImage = null;
      _isActive = true;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Banner added successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Banner Management')),
          body:
              viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (viewModel.errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 16),
                              color: Colors.red.shade100,
                              child: Text(
                                viewModel.errorMessage!,
                                style: TextStyle(color: Colors.red.shade900),
                              ),
                            ),
                          SizedBox(
                            height: 300,
                            child:
                                viewModel.banners.isEmpty
                                    ? const Center(
                                      child: Text(
                                        'No banners found',
                                        style: TextStyle(
                                          color: AppColors.scaffold,
                                        ),
                                      ),
                                    )
                                    : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: viewModel.banners.length,
                                      itemBuilder: (context, index) {
                                        final banner = viewModel.banners[index];
                                        return Card(
                                          margin: const EdgeInsets.only(
                                            bottom: 20,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              AspectRatio(
                                                aspectRatio: 16 / 9,
                                                child: Image.network(
                                                  banner.imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return const Center(
                                                      child: Text(
                                                        'Image load error',
                                                        style: TextStyle(
                                                          color:
                                                              AppColors
                                                                  .scaffold,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Text('Link: ${banner.link}'),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Status: ${banner.isActive ? 'Active' : 'Inactive'}',
                                                          style: TextStyle(
                                                            color:
                                                                AppColors
                                                                    .scaffold,
                                                          ),
                                                        ),
                                                        SizedBox(width: 16),
                                                        Switch(
                                                          value:
                                                              banner.isActive,
                                                          onChanged: (
                                                            value,
                                                          ) async {
                                                            await viewModel
                                                                .toggleBannerStatus(
                                                                  banner.id,
                                                                  value,
                                                                );
                                                          },
                                                        ),
                                                        SizedBox(width: 130),
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                          ),
                                                          onPressed: () async {
                                                            final confirm = await showDialog<
                                                              bool
                                                            >(
                                                              context: context,
                                                              builder:
                                                                  (
                                                                    context,
                                                                  ) => AlertDialog(
                                                                    title: const Text(
                                                                      'Delete Banner',
                                                                    ),
                                                                    content:
                                                                        const Text(
                                                                          'Are you sure you want to delete this banner?',
                                                                        ),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () => Navigator.of(
                                                                              context,
                                                                            ).pop(
                                                                              false,
                                                                            ),
                                                                        child: const Text(
                                                                          'Cancel',
                                                                        ),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () => Navigator.of(
                                                                              context,
                                                                            ).pop(
                                                                              true,
                                                                            ),
                                                                        child: const Text(
                                                                          'Delete',
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                            );
                                                            if (confirm ==
                                                                true) {
                                                              await viewModel
                                                                  .deleteBanner(
                                                                    banner.id,
                                                                    banner
                                                                        .imageUrl,
                                                                  );
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                    'Banner deleted',
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Align(
                                              //   alignment: Alignment.centerRight,
                                              //   child: IconButton(
                                              //     icon: const Icon(Icons.delete,
                                              //         color: Colors.red),
                                              //     onPressed: () async {
                                              //       final confirm = await showDialog<
                                              //           bool>(
                                              //         context: context,
                                              //         builder: (context) =>
                                              //             AlertDialog(
                                              //           title:
                                              //               const Text('Delete Banner'),
                                              //           content: const Text(
                                              //               'Are you sure you want to delete this banner?'),
                                              //           actions: [
                                              //             TextButton(
                                              //               onPressed: () =>
                                              //                   Navigator.of(context)
                                              //                       .pop(false),
                                              //               child:
                                              //                   const Text('Cancel'),
                                              //             ),
                                              //             TextButton(
                                              //               onPressed: () =>
                                              //                   Navigator.of(context)
                                              //                       .pop(true),
                                              //               child:
                                              //                   const Text('Delete'),
                                              //             ),
                                              //           ],
                                              //         ),
                                              //       );
                                              //       if (confirm == true) {
                                              //         await viewModel.deleteBanner(
                                              //             banner.id,
                                              //             banner.imageUrl);
                                              //         ScaffoldMessenger.of(context)
                                              //             .showSnackBar(
                                              //           const SnackBar(
                                              //               content:
                                              //                   Text('Banner deleted')),
                                              //         );
                                              //       }
                                              //     },
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                          ),
                          const Divider(height: 32),
                          const Text(
                            'Add New Banner',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: InkWell(
                              onTap: _selectImage,
                              child: Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child:
                                    _selectedImage != null
                                        ? Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                        )
                                        : const Center(
                                          child: Icon(
                                            Icons.add_photo_alternate,
                                            size: 50,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _linkController,
                            decoration: const InputDecoration(
                              labelText: 'Banner Link',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _addBanner(viewModel),
                            child: const Text('Add Banner'),
                          ),
                        ],
                      ),
                    ),
                  ),
        );
      },
    );
  }
}
