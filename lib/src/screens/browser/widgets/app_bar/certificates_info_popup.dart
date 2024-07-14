import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/providers/web_view_provider.dart';

class CertificatesInfoPopup extends StatefulWidget {
  const CertificatesInfoPopup({super.key});

  @override
  State<CertificatesInfoPopup> createState() => _CertificatesInfoPopupState();
}

class _CertificatesInfoPopupState extends State<CertificatesInfoPopup> {
  final List<X509Certificate> _otherCertificates = [];
  X509Certificate? _topMainCertificate;
  X509Certificate? _selectedCertificate;

  @override
  Widget build(BuildContext context) {
    return _build();
  }

  Widget _build() {
    if (_topMainCertificate == null) {
      var webViewProvider = Provider.of<WebViewProvider>(context, listen: true);

      return FutureBuilder(
        future: webViewProvider.webViewController?.getCertificate(),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState != ConnectionState.done) {
            return Container();
          }

          SslCertificate sslCertificate = snapshot.data as SslCertificate;
          _topMainCertificate = sslCertificate.x509Certificate;
          _selectedCertificate = _topMainCertificate!;

          return FutureBuilder(
            future: _getOtherCertificatesFromTopMain(
                _otherCertificates, _topMainCertificate!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return _buildCertificatesInfoAlertDialog();
              }
              return Center(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(2.5),
                    ),
                  ),
                  padding: const EdgeInsets.all(25.0),
                  width: 100.0,
                  height: 100.0,
                  child: const CircularProgressIndicator(
                    strokeWidth: 4.0,
                  ),
                ),
              );
            },
          );
        },
      );
    } else {
      return _buildCertificatesInfoAlertDialog();
    }
  }

  Future<void> _getOtherCertificatesFromTopMain(
      List<X509Certificate> otherCertificates,
      X509Certificate x509certificate) async {
    var authorityInfoAccess = x509certificate.authorityInfoAccess;
    if (authorityInfoAccess != null && authorityInfoAccess.infoAccess != null) {
      for (var i = 0; i < authorityInfoAccess.infoAccess!.length; i++) {
        try {
          var caIssuerUrl = authorityInfoAccess.infoAccess![i].location;
          HttpClientRequest request =
              await HttpClient().getUrl(Uri.parse(caIssuerUrl));
          HttpClientResponse response = await request.close();
          var certData = Uint8List.fromList(await response.first);
          var cert = X509Certificate.fromData(data: certData);
          otherCertificates.add(cert);
          await _getOtherCertificatesFromTopMain(otherCertificates, cert);
        } catch (e) {
          log(e.toString());
        }
      }
    }

    var cRLDistributionPoints = x509certificate.cRLDistributionPoints;

    if (cRLDistributionPoints != null && cRLDistributionPoints.crls != null) {
      for (var i = 0; i < cRLDistributionPoints.crls!.length; i++) {
        var crlUrl = cRLDistributionPoints.crls![i];
        try {
          HttpClientRequest request =
              await HttpClient().getUrl(Uri.parse(crlUrl));
          HttpClientResponse response = await request.close();
          var certData = Uint8List.fromList(await response.first);
          var cert = X509Certificate.fromData(data: certData);
          otherCertificates.add(cert);
          await _getOtherCertificatesFromTopMain(otherCertificates, cert);
        } catch (e) {
          log(e.toString());
        }
      }
    }
  }

  Widget _buildCertificatesInfoAlertDialog() {}
}
