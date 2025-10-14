import 'package:flutter/material.dart';
import 'package:turnable_page/turnable_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TurnablePage Minimal Example',
      debugShowCheckedModeBanner: false,
      home: const PageFlipDemo(),
    );
  }
}

class PageFlipDemo extends StatefulWidget {
  const PageFlipDemo({super.key});

  @override
  State<PageFlipDemo> createState() => _PageFlipDemoState();
}

class _PageFlipDemoState extends State<PageFlipDemo> {
  late PageFlipController _controller;

  // Toggle these to test which component causes issues
  // Start with everything OFF, then enable one at a time to find the culprit
  static const bool useStack = false;
  static const bool useScrollView = true;
  static const bool usePositionedIndicator = false;
  static const bool useEmptySizedBox = false;
  static const bool useBookCover = false;
  static const bool useBookMetadata = false;
  static const bool useConditionalWidget = false;

  @override
  void initState() {
    super.initState();
    _controller = PageFlipController();
  }

  Widget _buildPage(int index) {
    // Simple version without Stack
    if (!useStack) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Text(
            'Page ${index + 1}',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Build content
    Widget content = Column(
      children: [
        const SizedBox(height: 16),
        _PageIndicator(currentPage: index, totalPages: 3),
        if (useBookCover) _BookCoverWidget(pageIndex: index),
        if (useBookMetadata) _BookMetadataWidget(pageIndex: index),
        if (useConditionalWidget)
          if (index == 0)
            const _AdditionalInfoWidget()
          else
            const _SummaryWidget(),
      ],
    );

    // Optionally wrap in ScrollView
    if (useScrollView) {
      content = SingleChildScrollView(child: content);
    }

    // Build Stack layers
    List<Widget> stackChildren = [content];

    if (usePositionedIndicator) {
      stackChildren.add(
        Positioned(
          top: 16,
          right: 16,
          child: _PageIndicator(currentPage: index, totalPages: 3),
        ),
      );
    }

    if (useEmptySizedBox) {
      stackChildren.add(const SizedBox(height: 0, width: 0));
    }

    return Container(
      color: Colors.white,
      child: Stack(children: stackChildren),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Viewer'),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: () => _controller.previousPage(),
            child: const Icon(Icons.arrow_back),
          ),
          FloatingActionButton(
            onPressed: () => _controller.nextPage(),
            child: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: TurnablePage(
          controller: _controller,
          pageCount: 3,
          builder: (context, pageIndex, constraints) {
            return _buildPage(pageIndex);
          },
        ),
      ),
    );
  }
}

// Widget components
class _PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _PageIndicator({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${currentPage + 1} / $totalPages',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _BookCoverWidget extends StatelessWidget {
  final int pageIndex;

  const _BookCoverWidget({required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.primaries[pageIndex % Colors.primaries.length].shade300,
            Colors.primaries[pageIndex % Colors.primaries.length].shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book, size: 80, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              'Book ${pageIndex + 1}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookMetadataWidget extends StatelessWidget {
  final int pageIndex;

  const _BookMetadataWidget({required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book Metadata',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _MetadataRow(label: 'Title', value: 'Book ${pageIndex + 1}'),
          _MetadataRow(label: 'Author', value: 'Author ${pageIndex + 1}'),
          _MetadataRow(label: 'Pages', value: '${(pageIndex + 1) * 100}'),
          _MetadataRow(label: 'Year', value: '${2020 + pageIndex}'),
        ],
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetadataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _AdditionalInfoWidget extends StatelessWidget {
  const _AdditionalInfoWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              const Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _InfoRow(label: 'Category', value: 'Fiction'),
          const _InfoRow(label: 'Language', value: 'English'),
          const _InfoRow(label: 'ISBN', value: '978-3-16-148410-0'),
          const _InfoRow(label: 'Publisher', value: 'Example Press'),
        ],
      ),
    );
  }
}

class _SummaryWidget extends StatelessWidget {
  const _SummaryWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: Colors.green.shade700),
              const SizedBox(width: 8),
              const Text(
                'Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'This is a sample book with interesting content. '
            'It contains various chapters covering different topics. '
            'The book is well-structured and easy to follow.',
            style: TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
