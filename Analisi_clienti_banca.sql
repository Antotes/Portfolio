/* INDICATORI DI BASE */
/* 1. ETÀ */

/*tabella età */
CREATE TEMPORARY TABLE banca.eta(
	SELECT
		id_cliente,
		TIMESTAMPDIFF(YEAR, data_nascita, CURRENT_DATE()) AS eta
	FROM cliente
);



/* INDICATORI SULLE TRANSAZIONI */

/* tabella transazioni in uscita */
CREATE TEMPORARY TABLE banca.trans_out(
	SELECT 
		id_conto, 
		COUNT(*) AS num_trans_out_complessive,  /* numero di transazioni in uscita per id_conto.*/
		SUM(importo) AS importo_out_complessivo /* importo totale transato in uscita per id_conto.*/
	FROM transazioni
	WHERE importo < 0
	GROUP BY 1
);

/* tabella transazioni in entrata*/
CREATE TEMPORARY TABLE banca.trans_in(
	SELECT 
		id_conto, 
		COUNT(*) AS num_trans_in_complessive,     /* numero di transazioni in entrata per id_conto.*/
		SUM(importo) AS importo_in_complessivo    /* importo totale transato in entrata per id_conto.*/
	FROM transazioni
	WHERE importo > 0
	GROUP BY 1
);

/* tabella riassuntiva delle transazioni in entrata/uscita per id_conto*/
CREATE TEMPORARY TABLE banca.trans_summary_per_conto(
	SELECT * 
	FROM banca.trans_out
	INNER JOIN banca.trans_in USING (id_conto)
);

/* tabella riassuntiva delle transazioni in entrata/uscita per id_conto estesa*/
CREATE TEMPORARY TABLE banca.trans_summary_per_conto_ext(
	SELECT * 
	FROM conto
	INNER JOIN trans_summary_per_conto USING (id_conto)
);

/* tabella riassuntiva delle transazioni in entrata/uscita per id_cliente*/
CREATE TEMPORARY TABLE banca.trans_summary(
	SELECT 
		id_cliente,
		SUM(num_trans_out_complessive) AS num_trans_out_complessive, /* 2. NUMERO DI TRANSAZIONI IN USCITA SU TUTTI I CONTI.*/
		SUM(importo_out_complessivo) AS importo_out_complessivo,     /* 4. IMPORTO TOTALE TRANSATO IN USCITA SU TUTTI I CONTI.*/
		SUM(num_trans_in_complessive) AS num_trans_in_complessive,   /* 3. NUMERO DI TRANSAZIONI IN ENTRATA SU TUTTI I CONTI.*/
		SUM(importo_in_complessivo) AS importo_in_complessivo        /* 5. IMPORTO TOTALE TRANSATO IN ENTRATA SU TUTTI I CONTI.*/
	FROM trans_summary_per_conto_ext
	GROUP BY 1
	ORDER BY 1
);



/* INDICATORI SUI CONTI */

/* tabella riassuntiva del numero di conti totale e per tipologia raggruppati per id_cliente */
CREATE TEMPORARY TABLE banca.account_summary(
	SELECT 
		id_cliente,
		COUNT(id_tipo_conto) AS num_conti,  /* 6. NUMERO TOTALE DI CONTI POSSEDUTI.*/
		/* 7. NUMERO DI CONTI POSSEDUTI PER TIPOLOGIA (UN INDICATORE PER OGNI TIPO DI CONTO).*/
		SUM(CASE WHEN id_tipo_conto = 0 THEN 1 ELSE 0 END) AS num_conti_tipo_0, 
		SUM(CASE WHEN id_tipo_conto = 1 THEN 1 ELSE 0 END) AS num_conti_tipo_1,
		SUM(CASE WHEN id_tipo_conto = 2 THEN 1 ELSE 0 END) AS num_conti_tipo_2,
		SUM(CASE WHEN id_tipo_conto = 3 THEN 1 ELSE 0 END) AS num_conti_tipo_3
	FROM trans_summary_per_conto_ext
	GROUP BY 1
	ORDER BY 1
);



/* INDICATORI SULLE TRANSAZIONI PER TIPOLOGIA DI CONTO */
CREATE TEMPORARY TABLE banca.trans_summ_by_account(
	SELECT 
		id_cliente,

		/* indicatori sul conto 0 */
		SUM(CASE WHEN id_tipo_conto = 0 THEN num_trans_out_complessive ELSE 0 END) AS num_trans_out_conto_0, /* 8. NUMERO DI TRANSAZIONI IN USCITA PER TIPOLOGIA DI CONTO */
		SUM(CASE WHEN id_tipo_conto = 0 THEN importo_out_complessivo ELSE 0 END) AS importo_out_conto_0,     /* 10. IMPORTO TRANSATO IN USCITA PER TIPOLOGIA DI CONTO */
		SUM(CASE WHEN id_tipo_conto = 0 THEN num_trans_in_complessive ELSE 0 END) AS num_trans_in_conto_0,   /* 9. NUMERO DI TRANSAZIONI IN ENTRATA PER TIPOLOGIA DI CONTO */
		SUM(CASE WHEN id_tipo_conto = 0 THEN importo_in_complessivo ELSE 0 END) AS importo_in_conto_0,       /* 11. IMPORTO TRANSATO IN ENTRATA PER TIPOLOGIA DI CONTO */

		/* indicatori sul conto 1 */
		SUM(CASE WHEN id_tipo_conto = 1 THEN num_trans_out_complessive ELSE 0 END) AS num_trans_out_conto_1,
		SUM(CASE WHEN id_tipo_conto = 1 THEN importo_out_complessivo ELSE 0 END) AS importo_out_conto_1,
		SUM(CASE WHEN id_tipo_conto = 1 THEN num_trans_in_complessive ELSE 0 END) AS num_trans_in_conto_1,
		SUM(CASE WHEN id_tipo_conto = 1 THEN importo_in_complessivo ELSE 0 END) AS importo_in_conto_1,

		/* indicatori sul conto 2 */
		SUM(CASE WHEN id_tipo_conto = 2 THEN num_trans_out_complessive ELSE 0 END) AS num_trans_out_conto_2,
		SUM(CASE WHEN id_tipo_conto = 2 THEN importo_out_complessivo ELSE 0 END) AS importo_out_conto_2,
		SUM(CASE WHEN id_tipo_conto = 2 THEN num_trans_in_complessive ELSE 0 END) AS num_trans_in_conto_2,
		SUM(CASE WHEN id_tipo_conto = 2 THEN importo_in_complessivo ELSE 0 END) AS importo_in_conto_2,

		/* indicatori sul conto 3 */
		SUM(CASE WHEN id_tipo_conto = 3 THEN num_trans_out_complessive ELSE 0 END) AS num_trans_out_conto_3,
		SUM(CASE WHEN id_tipo_conto = 3 THEN importo_out_complessivo ELSE 0 END) AS importo_out_conto_3,
		SUM(CASE WHEN id_tipo_conto = 3 THEN num_trans_in_complessive ELSE 0 END) AS num_trans_in_conto_3,
		SUM(CASE WHEN id_tipo_conto = 3 THEN importo_in_complessivo ELSE 0 END) AS importo_in_conto_3

	FROM trans_summary_per_conto_ext
	GROUP BY 1
	ORDER BY 1
);



/* TABELLA CONCLUSIVA */

CREATE TEMPORARY TABLE banca.df(
	SELECT * 
	FROM eta
	LEFT JOIN trans_summary USING (id_cliente)
	LEFT JOIN account_summary USING (id_cliente)
	LEFT JOIN trans_summ_by_account USING (id_cliente)
	ORDER BY id_cliente
);


/*Non tutti i clienti presenti nella tabella cliente hanno un conto associato nella tabella conto.
  Per questi clienti si ha che tutti i campi, ad eccezzione di id_cliente ed età, risultano non popolati.
  
  Se non si possiede nessun conto non è possibile compiere operazioni in entrata o in uscita.
  Settiamo il valore di tali campi pari a 0, così da ottenere una tabella contente solo valori numerici.
  A seconda del tipo di task che andrà svolto in futuro sarà possibile rimuovere tali clienti filtrando solo i clienti con num_conti >= 1.*/

/*transazioni complessive*/  
UPDATE df SET num_trans_out_complessive = COALESCE(num_trans_out_complessive, 0);
UPDATE df SET importo_out_complessivo = COALESCE(importo_out_complessivo, 0);
UPDATE df SET num_trans_in_complessive = COALESCE(num_trans_in_complessive, 0);
UPDATE df SET importo_in_complessivo = COALESCE(importo_in_complessivo, 0);

/*numero conti*/
UPDATE df SET num_conti = COALESCE(num_conti, 0);
UPDATE df SET num_conti_tipo_0 = COALESCE(num_conti_tipo_0, 0);
UPDATE df SET num_conti_tipo_1 = COALESCE(num_conti_tipo_1, 0);
UPDATE df SET num_conti_tipo_2 = COALESCE(num_conti_tipo_2, 0);
UPDATE df SET num_conti_tipo_3 = COALESCE(num_conti_tipo_3, 0);

/*transazioni conto 0*/
UPDATE df SET num_trans_out_conto_0 = COALESCE(num_trans_out_conto_0, 0);
UPDATE df SET importo_out_conto_0 = COALESCE(importo_out_conto_0, 0);
UPDATE df SET num_trans_in_conto_0 = COALESCE(num_trans_in_conto_0, 0);
UPDATE df SET importo_in_conto_0 = COALESCE(importo_in_conto_0, 0);

/*transazioni conto 1*/
UPDATE df SET num_trans_out_conto_1 = COALESCE(num_trans_out_conto_1, 0);
UPDATE df SET importo_out_conto_1 = COALESCE(importo_out_conto_1, 0);
UPDATE df SET num_trans_in_conto_1 = COALESCE(num_trans_in_conto_1, 0);
UPDATE df SET importo_in_conto_1 = COALESCE(importo_in_conto_1, 0);

/*transazioni conto 2*/
UPDATE df SET num_trans_out_conto_2 = COALESCE(num_trans_out_conto_2, 0);
UPDATE df SET importo_out_conto_2 = COALESCE(importo_out_conto_2, 0);
UPDATE df SET num_trans_in_conto_2 = COALESCE(num_trans_in_conto_2, 0);
UPDATE df SET importo_in_conto_2 = COALESCE(importo_in_conto_2, 0);

/*transazioni conto 3*/
UPDATE df SET num_trans_out_conto_3 = COALESCE(num_trans_out_conto_3, 0);
UPDATE df SET importo_out_conto_3 = COALESCE(importo_out_conto_3, 0);
UPDATE df SET num_trans_in_conto_3 = COALESCE(num_trans_in_conto_3, 0);
UPDATE df SET importo_in_conto_3 = COALESCE(importo_in_conto_3, 0);

SELECT * FROM df;