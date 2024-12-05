import 'package:flutter/material.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../data/model/law.dart';
import 'dart:async';

class LawViewScreen extends StatefulWidget {
  final Law law;

  LawViewScreen({required this.law});

  @override
  _LawViewScreenState createState() => _LawViewScreenState();
}

class _LawViewScreenState extends State<LawViewScreen> {
  late PdfViewerController _pdfViewerController;
  PdfTextSearchResult _searchResult = PdfTextSearchResult();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final Map<String, PdfTextSearchResult> _searchCache = {};

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _performSearch(String searchQuery) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {
      if (searchQuery.isEmpty) {
        setState(() {
          _searchResult.clear();
        });
        return;
      }

      if (_searchCache.containsKey(searchQuery)) {
        setState(() {
          _searchResult = _searchCache[searchQuery]!;
        });
      } else {
        setState(() {
          _searchResult = _pdfViewerController.searchText(searchQuery);
          _searchCache[searchQuery] = _searchResult;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isSearching
            ? BackButton(onPressed: _clearSearch)
            : null,
        title: _buildTitle(),
        actions: _buildActions(),
      ),
      body: SfPdfViewer.network(
        widget.law.fileUrl,
        controller: _pdfViewerController,
      ),


        /*FileView(
          controller: FileViewController.network(widget.law.fileUrl),
        ),*/
    );
  }

  Widget _buildTitle() {
    return _isSearching
        ? TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Поиск...',
        border: InputBorder.none,
      ),
      onChanged: _performSearch,
    )
        : Text(widget.law.title);
  }

  List<Widget> _buildActions() {
    final List<Widget> actions = [];

    if (_isSearching && _searchResult.hasResult) {
      actions.addAll([
        Center(
          child: Text(
            '${_searchResult.currentInstanceIndex + 1} из ${_searchResult.totalInstanceCount}',
            style: TextStyle(fontSize: 16),
          ),
        ),
        IconButton(
          icon: Icon(Icons.navigate_before),
          onPressed: () {
            _searchResult.previousInstance();
            setState(() {});
          },
        ),
        IconButton(
          icon: Icon(Icons.navigate_next),
          onPressed: () {
            _searchResult.nextInstance();
            setState(() {});
          },
        ),
      ]);
    }

    if (!_isSearching) {
      actions.add(
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => setState(() => _isSearching = true),
        ),
      );
    }

    return actions;
  }

  void _clearSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchResult.clear();
    });
  }
}