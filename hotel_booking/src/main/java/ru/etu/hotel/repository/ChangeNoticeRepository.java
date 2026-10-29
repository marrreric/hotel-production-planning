package ru.etu.hotel.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import ru.etu.hotel.model.entity.ChangeNotice;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface ChangeNoticeRepository extends JpaRepository<ChangeNotice, Integer> {

    @Query(value = "SELECT bom_create_change(:number, :date, :description)", nativeQuery = true)
    Integer createChange(@Param("number") String number,
                         @Param("date") LocalDate date,
                         @Param("description") String description);

    @Query(value = "SELECT bom_close_change(:id)", nativeQuery = true)
    void closeChange(@Param("id") Integer id);

    @Query(value = "SELECT * FROM change_notice ORDER BY date, id", nativeQuery = true)
    List<ChangeNotice> findAllOrdered();
}