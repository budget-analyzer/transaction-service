package com.bleurubin.budgetanalyzer.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.bleurubin.budgetanalyzer.domain.Transaction;
import com.bleurubin.core.repository.SoftDeleteOperations;

public interface TransactionRepository
    extends JpaRepository<Transaction, Long>, SoftDeleteOperations<Transaction> {}
