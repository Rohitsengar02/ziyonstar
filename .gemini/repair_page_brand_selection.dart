// Brand and Model Selection Widgets

// Fetch models for a specific brand
Future<void> _fetchModelsForBrand(String brandId) async {
  setState(() => _isLoadingModels = true);
  try {
    final models = await _apiService.getModels(brandId);
    setState(() {
      _brandModels = models;
      _isLoadingModels = false;
    });
  } catch (e) {
    debugPrint('Error fetching models: $e');
    setState(() => _isLoadingModels = false);
  }
}

// Build brand selection grid (4x4 with "More" button)
Widget _buildBrandSelectionGrid(bool isDesktop, double padding) {
  final displayBrands = _apiBrands.take(15).toList();

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: padding, vertical: 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Device Brand',
          style: GoogleFonts.inter(
            fontSize: isDesktop ? 32 : 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textHeading,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Choose your device brand to see available models and repair prices',
          style: GoogleFonts.inter(fontSize: 16, color: AppColors.textBody),
        ),
        const SizedBox(height: 40),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 4 : 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.2,
          ),
          itemCount: displayBrands.length + 1,
          itemBuilder: (context, index) {
            if (index == displayBrands.length) {
              // "More" button
              return InkWell(
                onTap: _showChangeModelDialog,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryButton,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryButton.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.moreHorizontal,
                        size: 48,
                        color: AppColors.primaryButton,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'More Brands',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryButton,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final brand = displayBrands[index];
            return InkWell(
              onTap: () {
                setState(() {
                  _currentBrand = brand['title'] ?? '';
                  _selectionPhase = 'model';
                });
                _fetchModelsForBrand(brand['_id']);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.smartphone,
                      size: 48,
                      color: AppColors.primaryButton,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      brand['title'] ?? '',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}

// Build model selection grid with prices
Widget _buildModelSelectionGrid(bool isDesktop, double padding) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: padding, vertical: 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _selectionPhase = 'brand'),
              icon: const Icon(LucideIcons.arrowLeft, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select $_currentBrand Model',
                    style: GoogleFonts.inter(
                      fontSize: isDesktop ? 32 : 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textHeading,
                    ),
                  ),
                  Text(
                    'Choose your exact device model to see repair prices',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textBody,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        if (_isLoadingModels)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_brandModels.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                'No models available for this brand',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : 1,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: isDesktop ? 1.5 : 3,
            ),
            itemCount: _brandModels.length,
            itemBuilder: (context, index) {
              final model = _brandModels[index];
              final modelName = model['name'] ?? '';
              final basePrice = model['basePrice'] ?? 0;

              return InkWell(
                onTap: () {
                  setState(() {
                    _currentModel = modelName;
                    _modelData = model;
                    _selectionPhase = 'issues';
                    _selectedIssues.clear();
                  });
                  _fetchIssues();
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.smartphone,
                            size: isDesktop ? 32 : 24,
                            color: AppColors.primaryButton,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              modelName,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textHeading,
                                fontSize: isDesktop ? 18 : 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Starting from',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '₹$basePrice',
                            style: GoogleFonts.inter(
                              fontSize: isDesktop ? 24 : 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryButton,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    ),
  );
}

Future<void> _fetchIssues() async {
  try {
    final issues = await _apiService.getIssues();
    setState(() => _apiIssues = issues);
  } catch (e) {
    debugPrint('Error fetching issues: $e');
  }
}
