package com.velvet.api.billing.cbe;

import com.velvet.api.common.api.BusinessException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class CbeTransactionReferenceTest {

    @Test
    void normalizesOcrSeparatorsButKeepsTheEntireCbeFtCode() {
        assertEquals("FT2513001V2G", CbeVerifierClient.requireExactCbeReference("ft 2513-001-v2g"));
        assertEquals("FT26217SSG8W", CbeVerifierClient.requireExactCbeReference("Transaction ID: FT26217SSG8W"));
    }

    @Test
    void rejectsTruncatedOrNonCbeReferences() {
        assertThrows(BusinessException.class,
                () -> CbeVerifierClient.requireExactCbeReference("FT2513001V2"));
        assertThrows(BusinessException.class,
                () -> CbeVerifierClient.requireExactCbeReference("CE2513001XYT"));
    }

    @Test
    void decodesLiveVerifierPdfOctetStreamResponses() throws IOException {
        byte[] receipt = cbeReceiptPdf("""
                Payer: Hailegebrieal Yalember Account: ****1444
                Receiver: Dawit Sefie / Oz Kichen Account: ****9822
                Transferred Amount: 5500.00 ETB
                Reference No. (VAT Invoice No): FT26217SSG8W
                """);

        CbeVerifierClient.VerificationResult result = CbeVerifierClient.decodeVerifierBody(
                receipt,
                MediaType.APPLICATION_OCTET_STREAM,
                "FT26217SSG8W"
        );

        assertEquals(true, result.success());
        assertEquals("FT26217SSG8W", result.reference());
        assertEquals("5500.00", result.amountEtb().toPlainString());
    }

    @Test
    void rejectsLiveVerifierJsonErrors() throws Exception {
        byte[] body = new ObjectMapper().writeValueAsBytes(
                Map.of("success", false, "error", "Transaction not found"));

        BusinessException ex = assertThrows(BusinessException.class, () ->
                CbeVerifierClient.decodeVerifierBody(body, MediaType.APPLICATION_JSON, "FT26217SSG8W"));

        assertEquals("CBE_VERIFY_REJECTED", ex.getCode());
    }

    @Test
    void treatsVerifier422PdfMissAsRejectedNotUnhealthy() throws Exception {
        byte[] body = new ObjectMapper().writeValueAsBytes(Map.of(
                "success", false,
                "error", "Both direct and Puppeteer failed: Navigation timeout"
        ));

        BusinessException ex = CbeVerifierClient.mapVerifierHttpError(
                org.springframework.http.HttpStatus.UNPROCESSABLE_ENTITY,
                body
        );

        assertEquals("CBE_VERIFY_REJECTED", ex.getCode());
    }

    @Test
    void treatsMissingChromeAsUnavailableEvenOn422() throws Exception {
        byte[] body = new ObjectMapper().writeValueAsBytes(Map.of(
                "success", false,
                "error", "Both direct and Puppeteer failed: Could not find Chrome (ver. 136.0.7103.92)"
        ));
        BusinessException ex = CbeVerifierClient.mapVerifierHttpError(
                org.springframework.http.HttpStatus.UNPROCESSABLE_ENTITY, body);
        assertEquals("CBE_VERIFIER_UNAVAILABLE", ex.getCode());
        assertEquals(true, CbeVerifierClient.shouldFallbackToDirect(ex));
    }

    @Test
    void parsesTheExactReferenceAndMaskedReceiverAccountFromCbePdf() throws IOException {
        byte[] receipt = cbeReceiptPdf("""
                Payer: Hailegebrieal Yalember Account: ****1444
                Receiver: Dawit Sefie / Oz Kichen Account: ****5656
                Transferred Amount: 1290.00 ETB
                Reference No. (VAT Invoice No): FT26217SSG8W
                """);

        CbeVerifierClient.VerificationResult result =
                CbeVerifierClient.parseDirectPdf(receipt, "FT26217SSG8W");

        assertEquals(true, result.success());
        assertEquals("FT26217SSG8W", result.reference());
        assertEquals("****5656", result.receiverAccount());
        assertEquals("1290.00", result.amountEtb().toPlainString());
    }

    private static byte[] cbeReceiptPdf(String receiptText) throws IOException {
        try (PDDocument document = new PDDocument(); ByteArrayOutputStream output = new ByteArrayOutputStream()) {
            document.addPage(new PDPage());
            try (PDPageContentStream content = new PDPageContentStream(document, document.getPage(0))) {
                content.beginText();
                content.setFont(PDType1Font.HELVETICA, 12);
                content.newLineAtOffset(72, 700);
                for (String line : receiptText.strip().split("\\n")) {
                    content.showText(line.trim());
                    content.newLineAtOffset(0, -18);
                }
                content.endText();
            }
            document.save(output);
            return output.toByteArray();
        }
    }
}
