package ru.etu.hotel.service;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.etu.hotel.model.dto.request.*;
import ru.etu.hotel.model.dto.response.*;
import ru.etu.hotel.model.entity.BomSpecification;
import ru.etu.hotel.model.entity.BomSpecificationLine;
import ru.etu.hotel.model.entity.ChangeNotice;
import ru.etu.hotel.repository.BomSpecificationLineRepository;
import ru.etu.hotel.repository.BomSpecificationRepository;
import ru.etu.hotel.repository.ChangeNoticeRepository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class BomServiceImpl implements BomService {

    private final BomSpecificationRepository specRepository;
    private final BomSpecificationLineRepository lineRepository;
    private final ChangeNoticeRepository changeRepository;

    // ============ ЧТЕНИЕ ============

    @Override
    @Transactional(readOnly = true)
    public BomSpecificationResponse getSpecification(Integer specId) {
        BomSpecification spec = specRepository.findById(specId)
                .orElseThrow(() -> new EntityNotFoundException("Specification " + specId + " not found"));
        return toSpecResponse(spec);
    }

    @Override
    @Transactional(readOnly = true)
    public List<BomSpecificationResponse> listSpecifications() {
        List<BomSpecificationResponse> result = new ArrayList<>();
        for (BomSpecification s : specRepository.findAllOrdered()) {
            result.add(toSpecResponse(s));
        }
        return result;
    }

    @Override
    @Transactional(readOnly = true)
    public List<BomLineResponse> getLines(Integer specId, LocalDate onDate) {
        if (onDate == null) onDate = LocalDate.now();
        List<Object[]> rows = lineRepository.findLinesOnDate(specId, onDate);
        List<BomLineResponse> result = new ArrayList<>();
        for (Object[] r : rows) {
            result.add(BomLineResponse.builder()
                    .id(toInt(r[0]))
                    .specId(toInt(r[1]))
                    .componentId(toInt(r[2]))
                    .quantity(toBigDecimal(r[3]))
                    .eiId(toInt(r[4]))
                    .position(toInt(r[5]))
                    .build());
        }
        return result;
    }

    @Override
    @Transactional(readOnly = true)
    public List<BomExplodeResponse> explode(Integer specId, LocalDate onDate) {
        if (onDate == null) onDate = LocalDate.now();
        List<Object[]> rows = lineRepository.explode(specId, onDate);
        List<BomExplodeResponse> result = new ArrayList<>();
        for (Object[] r : rows) {
            result.add(BomExplodeResponse.builder()
                    .level(toInt(r[0]))
                    .parentId(toInt(r[1]))
                    .componentId(toInt(r[2]))
                    .componentName((String) r[3])
                    .categoryName((String) r[4])
                    .qtyPerParent(toBigDecimal(r[5]))
                    .qtyPerProduct(toBigDecimal(r[6]))
                    .unitName((String) r[7])
                    .hasSpec((Boolean) r[8])
                    .build());
        }
        return result;
    }

    @Override
    @Transactional(readOnly = true)
    public List<BomSumNormResponse> sumNorms(Integer productId, Integer classId,
                                              LocalDate onDate, Integer specId) {
        if (onDate == null) onDate = LocalDate.now();
        List<Object[]> rows = lineRepository.sumNorms(productId, classId, onDate, specId);
        List<BomSumNormResponse> result = new ArrayList<>();
        for (Object[] r : rows) {
            result.add(BomSumNormResponse.builder()
                    .componentId(toInt(r[0]))
                    .componentName((String) r[1])
                    .categoryName((String) r[2])
                    .totalNorm(toBigDecimal(r[3]))
                    .unitName((String) r[4])
                    .build());
        }
        return result;
    }

    @Override
    @Transactional(readOnly = true)
    public List<BomWhereUsedResponse> whereUsed(Integer componentId, LocalDate onDate) {
        if (onDate == null) onDate = LocalDate.now();
        List<Object[]> rows = lineRepository.whereUsed(componentId, onDate);
        List<BomWhereUsedResponse> result = new ArrayList<>();
        for (Object[] r : rows) {
            result.add(BomWhereUsedResponse.builder()
                    .level(toInt(r[0]))
                    .productId(toInt(r[1]))
                    .productName((String) r[2])
                    .build());
        }
        return result;
    }

    // ============ СОЗДАНИЕ СПЕЦИФИКАЦИЙ ============

    @Override
    public BomSpecificationResponse createBase(BomCreateBaseRequest request) {
        BomSpecification spec = new BomSpecification();
        spec.setProductId(request.getProductId());
        spec.setDesignation(request.getDesignation());
        spec.setSpecType("Базовая");
        spec.setStatus("Действует");
        spec.setDescription(request.getDescription());
        BomSpecification saved = specRepository.save(spec);
        log.info("Created base spec {} for product {}", saved.getId(), request.getProductId());
        return toSpecResponse(saved);
    }

    @Override
    public BomSpecificationResponse createModification(BomCreateModificationRequest request) {
        BomSpecification base = specRepository.findById(request.getBaseSpecId())
                .orElseThrow(() -> new EntityNotFoundException("Base spec not found"));
        if (!"Базовая".equals(base.getSpecType())) {
            throw new IllegalArgumentException("Модификация должна ссылаться на базовую спецификацию");
        }
        BomSpecification spec = new BomSpecification();
        spec.setProductId(request.getProductId());
        spec.setDesignation(request.getDesignation());
        spec.setSpecType("Модификация");
        spec.setBaseSpecId(request.getBaseSpecId());
        spec.setStatus("Действует");
        spec.setDescription(request.getDescription());
        BomSpecification saved = specRepository.save(spec);
        log.info("Created modification {} based on {}", saved.getId(), request.getBaseSpecId());
        return toSpecResponse(saved);
    }

    // ============ ИЗВЕЩЕНИЯ ============

    @Override
    public Integer createChange(BomCreateChangeRequest request) {
        Integer id = changeRepository.createChange(
                request.getNumber(), request.getDate(), request.getDescription());
        log.info("Created change notice {}", id);
        return id;
    }

    @Override
    public void closeChange(Integer changeId) {
        changeRepository.closeChange(changeId);
        log.info("Closed change notice {}", changeId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ChangeNotice> listChanges() {
        return changeRepository.findAllOrdered();
    }

    // ============ РАБОТА СО СТРОКАМИ ============

    @Override
    public Integer addLine(Integer specId, BomAddLineRequest request) {
        Integer lineId = lineRepository.addLine(
                specId, request.getComponentId(), request.getQuantity(),
                request.getEiId(), request.getChangeId(),
                request.getPosition() != null ? request.getPosition() : 0);
        log.info("Added line {} to spec {}", lineId, specId);
        return lineId;
    }

    @Override
    public Integer changeQty(Integer lineId, BomChangeQtyRequest request) {
        Integer newLineId = lineRepository.changeQty(
                lineId, request.getQuantity(), request.getChangeId());
        log.info("Changed qty on line {}, new line {}", lineId, newLineId);
        return newLineId;
    }

    @Override
    public void closeLine(Integer lineId, Integer changeId) {
        lineRepository.closeLine(lineId, changeId);
        log.info("Closed line {}", lineId);
    }

    @Override
    public Integer replaceComponent(Integer lineId, BomReplaceComponentRequest request) {
        Integer newLineId = lineRepository.replaceComponent(
                lineId, request.getNewComponentId(),
                request.getQuantity(), request.getChangeId());
        log.info("Replaced component on line {}, new line {}", lineId, newLineId);
        return newLineId;
    }

    @Override
    public Integer modExclude(Integer modSpecId, BomModExcludeRequest request) {
        Integer lineId = lineRepository.modExclude(
                modSpecId, request.getBaseComponentId(), request.getChangeId());
        log.info("Excluded component {} in mod spec {}", request.getBaseComponentId(), modSpecId);
        return lineId;
    }

    @Override
    public Integer modReplace(Integer modSpecId, BomModReplaceRequest request) {
        Integer lineId = lineRepository.modReplace(
                modSpecId, request.getBaseComponentId(), request.getNewComponentId(),
                request.getQuantity(), request.getEiId(), request.getChangeId());
        log.info("Replaced component {} in mod spec {}", request.getBaseComponentId(), modSpecId);
        return lineId;
    }
    @Override
@Transactional(readOnly = true)
public List<BomSumNormResponse> sumNormsForQty(Integer productId, Integer classId,
                                                java.math.BigDecimal quantity,
                                                java.time.LocalDate onDate, Integer specId) {
    if (onDate == null) onDate = java.time.LocalDate.now();
    List<Object[]> rows = lineRepository.sumNormsForQty(productId, classId, quantity, onDate, specId);
    List<BomSumNormResponse> result = new java.util.ArrayList<>();
    for (Object[] r : rows) {
        result.add(BomSumNormResponse.builder()
                .componentId(toInt(r[0]))
                .componentName((String) r[1])
                .categoryName((String) r[2])
                .totalNorm(toBigDecimal(r[3]))
                .unitName((String) r[4])
                .build());
    }
    return result;
}

    // ============ ВСПОМОГАТЕЛЬНЫЕ ============

    private BomSpecificationResponse toSpecResponse(BomSpecification s) {
        return BomSpecificationResponse.builder()
                .id(s.getId())
                .productId(s.getProductId())
                .designation(s.getDesignation())
                .specType(s.getSpecType())
                .baseSpecId(s.getBaseSpecId())
                .status(s.getStatus())
                .description(s.getDescription())
                .build();
    }

    private Integer toInt(Object o) {
        if (o == null) return null;
        if (o instanceof Number n) return n.intValue();
        return null;
    }

    private BigDecimal toBigDecimal(Object o) {
        if (o == null) return null;
        if (o instanceof BigDecimal b) return b;
        if (o instanceof Number n) return BigDecimal.valueOf(n.doubleValue());
        return new BigDecimal(o.toString());
    }
}