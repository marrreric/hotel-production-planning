package ru.etu.hotel.service;

import ru.etu.hotel.model.dto.request.*;
import ru.etu.hotel.model.dto.response.*;

import java.time.LocalDate;
import java.util.List;

public interface BomService {

    // Чтение
    BomSpecificationResponse getSpecification(Integer specId);
    List<BomSpecificationResponse> listSpecifications();
    List<BomLineResponse> getLines(Integer specId, LocalDate onDate);
    List<BomExplodeResponse> explode(Integer specId, LocalDate onDate);
    List<BomSumNormResponse> sumNorms(Integer productId, Integer classId, LocalDate onDate, Integer specId);
    List<BomWhereUsedResponse> whereUsed(Integer componentId, LocalDate onDate);

    // Создание спецификаций
    BomSpecificationResponse createBase(BomCreateBaseRequest request);
    BomSpecificationResponse createModification(BomCreateModificationRequest request);

    // Извещения
    Integer createChange(BomCreateChangeRequest request);
    void closeChange(Integer changeId);
    List<ru.etu.hotel.model.entity.ChangeNotice> listChanges();

    // Работа со строками
    Integer addLine(Integer specId, BomAddLineRequest request);
    Integer changeQty(Integer lineId, BomChangeQtyRequest request);
    void closeLine(Integer lineId, Integer changeId);
    Integer replaceComponent(Integer lineId, BomReplaceComponentRequest request);

    // Модификации
    Integer modExclude(Integer modSpecId, BomModExcludeRequest request);
    Integer modReplace(Integer modSpecId, BomModReplaceRequest request);

    List<BomSumNormResponse> sumNormsForQty(Integer productId, Integer classId, 
                                         java.math.BigDecimal quantity,
                                         java.time.LocalDate onDate, Integer specId);
}