import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../models/pdf_extracted_item.dart';
import '../services/api_service.dart';

class PdfUploadReviewModal extends StatefulWidget {
  final Uint8List? initialPdfBytes;
  final String? initialFileName;

  const PdfUploadReviewModal({
    super.key,
    this.initialPdfBytes,
    this.initialFileName,
  });

  static Future<void> show(BuildContext context, {Uint8List? pdfBytes, String? fileName}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PdfUploadReviewModal(
        initialPdfBytes: pdfBytes,
        initialFileName: fileName,
      ),
    );
  }

  @override
  State<PdfUploadReviewModal> createState() => _PdfUploadReviewModalState();
}

class _PdfUploadReviewModalState extends State<PdfUploadReviewModal> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  PdfExtractionResult? _extractionResult;
  String? _targetStoreId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final storeProvider = context.read<StoreProvider>();
    _targetStoreId = storeProvider.currentStore.id;

    if (widget.initialPdfBytes != null) {
      _processPdf(widget.initialPdfBytes!, widget.initialFileName ?? 'pedido_fornecedor.pdf');
    } else {
      // Carregar exemplo imediatamente para demonstração rápida caso o usuário não tenha selecionado arquivo do disco
      _processPdf(Uint8List(0), 'pedido_distribuidora.pdf');
    }
  }

  Future<void> _processPdf(Uint8List bytes, String filename) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiService.extractPdfFromBytes(
        fileBytes: bytes,
        filename: filename,
      );
      setState(() {
        _extractionResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Falha ao processar o PDF: $e';
        _isLoading = false;
      });
    }
  }

  double get _currentCalculatedTotal {
    if (_extractionResult == null) return 0.0;
    return _extractionResult!.items.fold(0.0, (acc, item) => acc + item.subtotal);
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final stores = storeProvider.stores;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        children: [
          // Barra de Arrastar (Handle)
          Container(
            margin: const EdgeInsets.only(top: 10.0, bottom: 6.0),
            width: 40.0,
            height: 4.5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),

          // Cabeçalho Modal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Revisão de Itens do PDF',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      _extractionResult?.detectedSupplier ?? 'Distribuidora de Alimentos',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(backgroundColor: Colors.grey.shade200),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Corpo da Lista ou Carregamento
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Analisando tabelas e subtotais no PDF...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : _buildReviewContent(stores),
          ),

          // Rodapé Fixo com Resumo Financeiro e Ação de Mesclar
          if (_extractionResult != null && _extractionResult!.items.isNotEmpty)
            _buildFooter(storeProvider),
        ],
      ),
    );
  }

  Widget _buildReviewContent(List<dynamic> stores) {
    final items = _extractionResult!.items;

    return Column(
      children: [
        // Seletor da Loja de Destino
        Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: Colors.grey.shade300, width: 0.8),
          ),
          child: Row(
            children: [
              const Icon(Icons.storefront, color: Color(0xFF007AFF), size: 22),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Loja de Destino:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              DropdownButton<String>(
                value: _targetStoreId,
                underline: const SizedBox(),
                borderRadius: BorderRadius.circular(12),
                items: stores.map<DropdownMenuItem<String>>((s) {
                  return DropdownMenuItem<String>(
                    value: s.id,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: s.color),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${s.code} - ${s.name}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _targetStoreId = val;
                  });
                },
              ),
            ],
          ),
        ),

        // Lista de Itens Editáveis
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildItemCard(item, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(PdfExtractedItem item, int index) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Detalhes do Produto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  'R\$ ${item.unitPrice.toStringAsFixed(2).replaceAll('.', ',')} / ${item.unit}',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Stepper de Quantidade
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    if (item.quantity > 1) {
                      setState(() {
                        item.updateQuantity(item.quantity - 1);
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(8.0),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Icon(Icons.remove, size: 16.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(
                    '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      item.updateQuantity(item.quantity + 1);
                    });
                  },
                  borderRadius: BorderRadius.circular(8.0),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Icon(Icons.add, size: 16.0),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Subtotal Calculado
          SizedBox(
            width: 72,
            child: Text(
              'R\$ ${item.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Color(0xFF007AFF),
              ),
            ),
          ),

          // Excluir Item
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
            onPressed: () {
              setState(() {
                _extractionResult!.items.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(StoreProvider storeProvider) {
    final totalValue = _currentCalculatedTotal;
    final count = _extractionResult!.items.length;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resumo: $count itens',
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Total: R\$ ${totalValue.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF007AFF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
                onPressed: () {
                  if (_targetStoreId != null && _extractionResult != null) {
                    storeProvider.mergeExtractedPdfItems(
                      _targetStoreId!,
                      _extractionResult!.items,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$count itens mesclados com sucesso!'),
                        backgroundColor: const Color(0xFF34C759),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Mesclar Itens na Lista da Loja',
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
