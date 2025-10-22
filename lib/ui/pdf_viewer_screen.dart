import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart'; // Importa o pacote pdfx
import 'package:path/path.dart' as p; // Para extrair o nome do ficheiro

class PdfViewerScreen extends StatefulWidget {
  final String filePath; // Recebe o caminho do ficheiro PDF

  const PdfViewerScreen({super.key, required this.filePath});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  // Controlador para gerir o documento PDF
  // CORREÇÃO: Inicializamos o controlador diretamente aqui
  late PdfController _pdfController;
  bool _isLoading = true; // Indica se o PDF está a carregar
  String? _error; // Guarda mensagens de erro, se houver
  int _currentPage = 1; // Página atual
  int _pageCount = 0; // Número total de páginas

  @override
  void initState() {
    super.initState();
    // CORREÇÃO: Passamos a Future diretamente para o controlador
    _pdfController = PdfController(
      document: PdfDocument.openFile(widget.filePath),
    );
    // Não precisamos mais de _loadPdf, o controlador gere o carregamento
    // _loadPdf(); // <--- REMOVIDO
  }

  // A função _loadPdf() foi removida pois o PdfController agora gere o carregamento inicial.
  // A lógica de _pageCount será obtida através do listener do controlador, se necessário,
  // ou podemos obter do document quando estiver pronto.
  // Para simplificar, vamos obter o pageCount quando o build for chamado pela primeira vez.

  @override
  void dispose() {
    // Libera os recursos do controlador ao sair da tela
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Mostra o nome do ficheiro PDF no título da barra
        title: Text(p.basename(widget.filePath)),
        backgroundColor: const Color(0xFF1E3A4B), // Cor da barra
        // Mostra o contador de páginas (ex: 1/10) na barra
        actions: [
          // Usamos um PdfPageNumber para mostrar o contador de forma mais robusta
          PdfPageNumber(
            controller: _pdfController,
            builder: (_, loadingState, page, pagesCount) => Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: page == null || pagesCount == null
                  ? const SizedBox() // Não mostra nada enquanto carrega
                  : Text(
                      '$page/$pagesCount', // Exibe pagina atual / total
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.grey.shade300, // Fundo claro para contraste
      // Usamos PdfView.builder para lidar com o estado de carregamento
      body: PdfView(
        controller: _pdfController,
        scrollDirection: Axis.vertical, // Rola na vertical
        // Atualiza o número da página atual (se precisarmos fora do PdfPageNumber)
        // onPageChanged: (page) {
        //   setState(() {
        //     _currentPage = page;
        //   });
        // },
        // Configurações visuais do visualizador (indicadores de loading, etc.)
        builders: PdfViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          pageLoaderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          errorBuilder: (_, error) => Center(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Erro ao carregar PDF: ${error.toString()}",
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          )),
        ),
      ),
    );
  }
}
