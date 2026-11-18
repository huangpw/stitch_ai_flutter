import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

enum StatsReportFormat { excel, pdf }

/// 导出屏幕上的统计汇总，不把月度汇总伪装成逐笔流水。
class StatsReport {
  StatsReport._();

  static const categories = <(String, double)>[
    ('日常消费', 8450),
    ('AI 算力订阅', 1248.5),
  ];
  static const breakdown = <(String, double)>[
    ('居住房租', 3500),
    ('餐饮美食', 3240),
    ('AI 算力订阅', 1248.5),
    ('交通出行', 680),
    ('其他支出', 1030),
  ];

  static Future<void> share({
    required StatsReportFormat format,
    required String period,
    required bool hasData,
    Rect? shareOrigin,
  }) async {
    final bytes = await build(format: format, period: period, hasData: hasData);
    final extension = format == StatsReportFormat.excel ? 'xlsx' : 'pdf';
    final name = '账单统计_${period.replaceAll(' ', '')}.$extension';
    await SharePlus.instance.share(
      ShareParams(
        title: '账单统计 · $period',
        files: [
          XFile.fromData(
            bytes,
            mimeType: format == StatsReportFormat.excel
                ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                : 'application/pdf',
          ),
        ],
        fileNameOverrides: [name],
        sharePositionOrigin: shareOrigin,
        downloadFallbackEnabled: true,
      ),
    );
  }

  static Future<Uint8List> build({
    required StatsReportFormat format,
    required String period,
    required bool hasData,
  }) async => switch (format) {
    StatsReportFormat.excel => _excel(period, hasData),
    StatsReportFormat.pdf => _pdf(period, hasData),
  };

  static Uint8List _excel(String period, bool hasData) {
    final workbook = Excel.createExcel();
    final sheet = workbook['账单统计'];
    workbook.delete('Sheet1');
    void row(List<String> labels) =>
        sheet.appendRow(labels.map(TextCellValue.new).toList());
    row(['账单统计', period]);
    row(['总支出', '人民币']);
    sheet.appendRow([
      TextCellValue('合计'),
      DoubleCellValue(hasData ? 9698.5 : 0),
    ]);
    if (hasData) {
      row(['分类', '金额', '占比']);
      for (final (title, amount) in breakdown) {
        sheet.appendRow([
          TextCellValue(title),
          DoubleCellValue(amount),
          TextCellValue('${(amount / 9698.5 * 100).toStringAsFixed(1)}%'),
        ]);
      }
      row([]);
      row(['预算', '金额', '已用', '剩余额度']);
      sheet.appendRow([
        TextCellValue('月预算'),
        DoubleCellValue(12000),
        DoubleCellValue(9698.5),
        DoubleCellValue(2301.5),
      ]);
      sheet.appendRow([
        TextCellValue('AI 专属预算'),
        DoubleCellValue(1500),
        DoubleCellValue(1248.5),
        DoubleCellValue(251.5),
      ]);
      row([]);
      row(['模型服务', '金额']);
      sheet.appendRow([TextCellValue('Claude Pro'), DoubleCellValue(145)]);
      sheet.appendRow([TextCellValue('OpenAI API'), DoubleCellValue(360)]);
    } else {
      row(['暂无数据']);
    }
    sheet.setColumnWidth(0, 24);
    sheet.setColumnWidth(1, 24);
    sheet.setColumnWidth(2, 18);
    sheet.setColumnWidth(3, 18);
    for (final cell in sheet.rows.first) {
      cell?.cellStyle = CellStyle(
        bold: true,
        fontSize: 16,
        fontColorHex: ExcelColor.fromHexString('#059669'),
      );
    }
    return Uint8List.fromList(workbook.encode()!);
  }

  static Future<Uint8List> _pdf(String period, bool hasData) async {
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/StatsReportSC.ttf'),
    );
    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: font),
    );
    final green = PdfColor.fromHex('#059669');
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Text('账单统计', style: pw.TextStyle(fontSize: 24, color: green)),
          pw.SizedBox(height: 8),
          pw.Text(period, style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 24),
          pw.Text(
            '总支出  ¥${hasData ? '9,698.50' : '0.00'}',
            style: const pw.TextStyle(fontSize: 22),
          ),
          pw.SizedBox(height: 20),
          if (hasData) ...[
            pw.TableHelper.fromTextArray(
              headers: ['分类', '金额', '占比'],
              data: [
                for (final (title, amount) in breakdown)
                  [
                    title,
                    '¥${amount.toStringAsFixed(2)}',
                    '${(amount / 9698.5 * 100).toStringAsFixed(1)}%',
                  ],
              ],
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#ECFDF5'),
              ),
              cellPadding: const pw.EdgeInsets.all(10),
              border: pw.TableBorder.all(color: PdfColor.fromHex('#E2E8F0')),
            ),
            pw.SizedBox(height: 24),
            pw.Text('预算', style: pw.TextStyle(fontSize: 16, color: green)),
            pw.SizedBox(height: 12),
            pw.Text('月预算 ¥12,000.00    已用 80.8%    剩余额度 ¥2,301.50'),
            pw.SizedBox(height: 8),
            pw.Text('AI 专属预算 ¥1,500.00    已用 83.2%    剩余额度 ¥251.50'),
            pw.SizedBox(height: 24),
            pw.Text('模型服务', style: pw.TextStyle(fontSize: 16, color: green)),
            pw.SizedBox(height: 12),
            pw.Text('Claude Pro  ¥145.00    OpenAI API  ¥360.00'),
          ] else
            pw.Text('暂无数据'),
        ],
      ),
    );
    return document.save();
  }
}
