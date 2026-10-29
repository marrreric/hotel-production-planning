package ru.etu.hotel.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ru.etu.hotel.model.dto.request.*;
import ru.etu.hotel.model.dto.response.*;
import ru.etu.hotel.model.entity.ChangeNotice;
import ru.etu.hotel.service.BomService;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/bom")
@RequiredArgsConstructor
@Slf4j
public class BomController {

    private final BomService bomService;

    // ============ ЧТЕНИЕ ============

    @GetMapping("/specifications")
    public ResponseEntity<List<BomSpecificationResponse>> listSpecifications() {
        return ResponseEntity.ok(bomService.listSpecifications());
    }

    @GetMapping("/specifications/{specId}")
    public ResponseEntity<BomSpecificationResponse> getSpecification(@PathVariable Integer specId) {
        return ResponseEntity.ok(bomService.getSpecification(specId));
    }

    @GetMapping("/specifications/{specId}/lines")
    public ResponseEntity<List<BomLineResponse>> getLines(
            @PathVariable Integer specId,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate onDate) {
        return ResponseEntity.ok(bomService.getLines(specId, onDate));
    }

    @GetMapping("/specifications/{specId}/explode")
    public ResponseEntity<List<BomExplodeResponse>> explode(
            @PathVariable Integer specId,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate onDate) {
        return ResponseEntity.ok(bomService.explode(specId, onDate));
    }

    @GetMapping("/products/{productId}/sum-norms")
    public ResponseEntity<List<BomSumNormResponse>> sumNorms(
            @PathVariable Integer productId,
            @RequestParam Integer classId,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate onDate,
            @RequestParam(required = false) Integer specId) {
        return ResponseEntity.ok(bomService.sumNorms(productId, classId, onDate, specId));
    }

    @GetMapping("/products/{productId}/sum-norms-for-qty")
    public ResponseEntity<List<BomSumNormResponse>> sumNormsForQty(
            @PathVariable Integer productId,
            @RequestParam Integer classId,
            @RequestParam BigDecimal quantity,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate onDate,
            @RequestParam(required = false) Integer specId) {
        return ResponseEntity.ok(bomService.sumNormsForQty(productId, classId, quantity, onDate, specId));
    }

    @GetMapping("/components/{componentId}/where-used")
    public ResponseEntity<List<BomWhereUsedResponse>> whereUsed(
            @PathVariable Integer componentId,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate onDate) {
        return ResponseEntity.ok(bomService.whereUsed(componentId, onDate));
    }

    // ============ СОЗДАНИЕ СПЕЦИФИКАЦИЙ ============

    @PostMapping("/specifications")
    public ResponseEntity<BomSpecificationResponse> createBase(
            @RequestBody BomCreateBaseRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(bomService.createBase(request));
    }

    @PostMapping("/specifications/{baseSpecId}/modifications")
    public ResponseEntity<BomSpecificationResponse> createModification(
            @PathVariable Integer baseSpecId,
            @RequestBody BomCreateModificationRequest request) {
        request.setBaseSpecId(baseSpecId);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(bomService.createModification(request));
    }

    // ============ ИЗВЕЩЕНИЯ ============

    @GetMapping("/changes")
    public ResponseEntity<List<ChangeNotice>> listChanges() {
        return ResponseEntity.ok(bomService.listChanges());
    }

    @PostMapping("/changes")
    public ResponseEntity<Map<String, Integer>> createChange(
            @RequestBody BomCreateChangeRequest request) {
        Integer id = bomService.createChange(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("id", id));
    }

    @PostMapping("/changes/{id}/close")
    public ResponseEntity<Map<String, String>> closeChange(@PathVariable Integer id) {
        bomService.closeChange(id);
        return ResponseEntity.ok(Map.of("message", "Change notice closed"));
    }

    // ============ РАБОТА СО СТРОКАМИ ============

    @PostMapping("/specifications/{specId}/lines")
    public ResponseEntity<Map<String, Integer>> addLine(
            @PathVariable Integer specId,
            @RequestBody BomAddLineRequest request) {
        Integer lineId = bomService.addLine(specId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("lineId", lineId));
    }

    @PatchMapping("/lines/{lineId}/quantity")
    public ResponseEntity<Map<String, Integer>> changeQty(
            @PathVariable Integer lineId,
            @RequestBody BomChangeQtyRequest request) {
        Integer newLineId = bomService.changeQty(lineId, request);
        return ResponseEntity.ok(Map.of("newLineId", newLineId));
    }

    @PostMapping("/lines/{lineId}/close")
    public ResponseEntity<Map<String, String>> closeLine(
            @PathVariable Integer lineId,
            @RequestBody BomChangeQtyRequest request) {
        bomService.closeLine(lineId, request.getChangeId());
        return ResponseEntity.ok(Map.of("message", "Line closed"));
    }

    @PostMapping("/lines/{lineId}/replace")
    public ResponseEntity<Map<String, Integer>> replaceComponent(
            @PathVariable Integer lineId,
            @RequestBody BomReplaceComponentRequest request) {
        Integer newLineId = bomService.replaceComponent(lineId, request);
        return ResponseEntity.ok(Map.of("newLineId", newLineId));
    }

    // ============ МОДИФИКАЦИИ ============

    @PostMapping("/specifications/{specId}/exclusions")
    public ResponseEntity<Map<String, Integer>> modExclude(
            @PathVariable Integer specId,
            @RequestBody BomModExcludeRequest request) {
        Integer lineId = bomService.modExclude(specId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("lineId", lineId));
    }

    @PostMapping("/specifications/{specId}/replacements")
    public ResponseEntity<Map<String, Integer>> modReplace(
            @PathVariable Integer specId,
            @RequestBody BomModReplaceRequest request) {
        Integer lineId = bomService.modReplace(specId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("lineId", lineId));
    }
}