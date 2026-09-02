--select distinct distributor from Cashmemo where delv_date>='20230101'
--select * from DISTRIBUTOR
IF OBJECT_ID('tempdb..#TEMP_SecondarySalesOut') IS NOT NULL
Begin
    DROP TABLE #TEMP_SecondarySalesOut;
END

                            if exists (select 1 from tempdb.dbo.sysobjects o where o.xtype in ('U') and o.id = object_id(N'TEMPDB..#TEMP_HEADER')) 
                            BEGIN drop table #TEMP_HEADER END;
                              WITH T  AS 
(
SELECT '26' COMPANY,  DISTRIBUTOR DISTRIBUTOR, '360874352' FRV, '361360667' TRV  from DISTRIBUTOR where working_date>='20230601'
)
SELECT 
DISTINCT cd.COMPANY, cd.distributor  [Distributor],
d.NAME [Distributor Name],
cd.PROJECT_CODE,
D.DIST_TYPE [Dist Type],
cm.DOCUMENT [DocumentType],
cm.Town [Town],
TW.LDESC [Town Name],
cm.doc_no [DocumentNumber],
cm.SUB_DOCUMENT [SubDocument],
CASE WHEN cm.DOCUMENT = 'CM' and cm.SUB_DOCUMENT in ('02','04') THEN cm.DOCUMENT ELSE '' END [ReferenceDocumentType],
CASE WHEN cm.DOCUMENT = 'CM' and cm.SUB_DOCUMENT in ('02','04') THEN cm.REF_DOC_NO ELSE '' END [ReferenceDocumentNumber],
CASE WHEN cm.DOCUMENT = 'CM' and cm.SUB_DOCUMENT in ('02','04') THEN cm.SUB_DOCUMENT ELSE '' END [ReferenceSubDocument],
cm.PJP [RouteID],
cm.DSR [Salesman],
cm.SECTION [Section],
isnull(ps.SCHEDULED,0) [Scheduled],
cm.RECEIVED_AMT [ReceivedAmount],
CONVERT(varchar,cm.DOC_DATE,21) [DocumentDate],
CONVERT(varchar,cm.DELV_DATE,21) [DeliveryDate],
cm.REF_DSR [Deliveryman],
cm.REF_PJP [DeliveryRouteID],
cm.NET_AMOUNT [NetAmount],
CM.DISTRIBUTOR+cm.TOWN+cm.Locality+cm.SLOCALITY+cm.POP [OutletId],
CM.POP_NAME [Outlet Name],
cm.WAREHOUSE [Warehouse],
cd.SKU [ProductID],

CASE when cd.SKU_TYPE  = '01' then 'N'  when cd.SKU_TYPE  = '02' then 'D' when cd.SKU_TYPE  = '03' then 'E' when cd.SKU_TYPE  = '04' then 'Q'  else 'N' end [ProductType],
cd.BATCH [BatchID],
cd.QuantityDemanded [QuantityDemanded],
cd.QuantityOrdered [QuantityOrdered],
cd.QuantityDelivered [QuantityDelivered],
cd.QTY1 [QTTY1],
cd.ProductWeight [ProductWeight],
cd.amount [GrossAmount],
cd.GST [Tax],
cd.GST_PERCENTAGE [TaxPercentage],
cd.Ref_type [ReasonCode],
cd.PriceCode [PriceCode],
cd.BatchExpiryDate [BatchExpiryDate],
cd.FreeGoodsIndicator [FreeGoodsIndicator],
cd.PromotionID [PromotionID],
cd.PromotionType [PromotionType],
cd.TDiscount [DiscountAmount],
InvoiceType [InvoiceType],
p.PREV_POP_CODE [PreviousePOPCode],
isnull(ds.VEHICLE,'') [VehicleNo],
'03' [WHTaxCode],
ISNULL(td.Rate ,0.0) [WHTaxRate],
ISNULL(rh.NET_AMOUNT ,0.0) [WHTAmount],
ISNULL((cd.amount/ nullif(cd.QuantityDelivered,0)),0.0) [UnitPrice]
into #Temp_SecondarySalesOut FROM T 
 INNER JOIN distributor d on T.company = d.company and T.distributor = d.distributor
INNER JOIN CASHMEMO cm on cm.company = d.company and cm.DISTRIBUTOR = d.distributor AND cm.VISIT_TYPE='02' 
--INNER JOIN ( select dll.company, dll.distributor,  (select top 1 working_Date from DAYEND_LOG dl where dll.COMPANY = dl.COMPANY and dll.DISTRIBUTOR = dl.DISTRIBUTOR and dll.WORKING_DATE> dl.WORKING_DATE order by dl.WORKING_DATE desc) WORKING_DATE from DAYEND_LOG dll inner join t on t.COMPANY = dll.COMPANY and t.DISTRIBUTOR = dll.DISTRIBUTOR and dll.IROW_VER >= t.FRV and dll.type='P-DIST-'+ t.distributor ) de ON cm.company= de.company and cm.distributor = de.distributor AND de.WORKING_DATE  = cm.DELV_DATE 
LEFT JOIN DSR ds on cm.company = ds.company and cm.distributor = ds.distributor and cm.ref_dsr = ds.dsr
LEFT JOIN TOWN TW on cm.company = TW.company and cm.TOWN = TW.TOWN 
INNER JOIN POP P on cm.company = P.company  and cm.DISTRIBUTOR = P.distributor and cm.TOWN = P.TOWN and cm.LOCALITY = P.LOCALITY and cm.SLOCALITY = P.SLOCALITY and cm.POP = P.POP 
LEFT JOIN POP_TAX pt on cm.company = Pt.company  and cm.distributor = Pt.distributor  and  cm.TOWN = Pt.TOWN and cm.LOCALITY = Pt.LOCALITY and cm.SLOCALITY = Pt.SLOCALITY and cm.POP = Pt.POP
LEFT JOIN TAX_DETAIL td on pt.COMPANY=td.COMPANY and pt.TAX_ID=td.TAX_ID and pt.SLAB=td.SLAB and pt.TAX_ID= (select PARAMETER_VALUE from  APPLICATION_SETUP where PARAMETER_ID = 'WHT_TAX_ID')
LEFT JOIN RECEIPT_HEAD rh on cm.company = rh.company and cm.DISTRIBUTOR = rh.distributor and rh.DOCUMENT='CN' and  rh.SUB_DOCUMENT='20' and rh.REF_DOCUMENT ='CM' and rh.REF_DOC_NO = cm.DOC_NO
LEFT JOIN POP_STATUS ps on cm.company = ps.company and cm.distributor = ps.distributor and cm.pjp = ps.pjp and cm.town = ps.town and cm.locality = ps.locality and cm.slocality = ps.slocality and cm.pop = ps.pop and cm.doc_Date = ps.status_Date and cm.sell_category = ps.sell_category and cm.section = ps.section
LEFT JOIN (select cd.COMPANY, cd.DISTRIBUTOR, cd.DOCUMENT, cd.SUB_DOCUMENT, cd.DOC_NO, cd.ENTRY_TYPE, cd.SKU, cd.SKU_TYPE, cd.BATCH, cd.WAREHOUSE, cd.REF_QTY1, cd.REF_QTY2, cd.REF_QTY3, cd.ORD_QTY1, 
cd.ORD_QTY2, cd.ORD_QTY3,cd.QTY1, cd.QTY2, cd.QTY3, cd.AMOUNT, cd.GST, cd.GST_PERCENTAGE, cd.Ref_type, 0 FreeGoodsIndicator, '' PromotionID, 0 SDiscount, 0 TDiscount, '' PromotionType , '1' InvoiceType ,
(cd.REF_QTY1 * b.SELL_FACTOR1 + cd.REF_QTY2 * b.SELL_FACTOR2 + cd.REF_QTY3 * b.SELL_FACTOR3) [QuantityDemanded],
(cd.ORD_QTY1 * b.SELL_FACTOR1 + cd.ORD_QTY2 * b.SELL_FACTOR2 + cd.ORD_QTY3 * b.SELL_FACTOR3) [QuantityOrdered]

,(cd.QTY1 * b.SELL_FACTOR1 + cd.QTY2 * b.SELL_FACTOR2 + cd.QTY3 * b.SELL_FACTOR3) QuantityDelivered,0 [QTTY1],

(cd.QTY1 * b.SELL_WEIGHT1 + cd.QTY2 * b.SELL_WEIGHT2 + cd.QTY3 * b.SELL_WEIGHT3) 
[ProductWeight],b.Price_struc [PriceCode],CONVERT(varchar,b.expiry,21) [BatchExpiryDate] ,'' PROJECT_CODE from cashmemo_Detail cd INNER JOIN T on cd.company = t.company
and cd.DISTRIBUTOR = t.distributor
  INNER JOIN BATCH b on b.company = cd.company and b.sku = cd.sku and b.batch = cd.batch UNION ALL select sdd.COMPANY, sdd.DISTRIBUTOR, sdd.DOCUMENT, sdd.SUB_DOCUMENT, sdd.DOC_NO, '01' ENTRY_TYPE, sdd.SKU, 
  '01' SKU_TYPE, sdd.BATCH, '01' WAREHOUSE, 0 REF_QTY1, 0 REF_QTY2, 0 REF_QTY3, 0 ORD_QTY1, 0 ORD_QTY2, 0 ORD_QTY3, 0 QTY1, 0 QTY2, 0 QTY3, 0 AMOUNT, sdd.GST, 
  abs(case when sdd.discount = 0 then 0 else sdd.GST/sdd.DISCOUNT end *100) GST_PERCENTAGE, null Ref_type, 0 FreeGoodsIndicator, sdd.mp_code+ sdd.seq_id PromotionID, 
  case sd.scheme_type when 'T' then 0 else sdd.discount end SDiscount, case sd.scheme_type when 'T' then sdd.discount else sdd.discount end TDiscount , isnull(ST.LDESC,'') [PromotionType],'2' InvoiceType ,
  0 [QuantityDemanded],  0[QuantityOrdered],

  0 QuantityDelivered,0 [QTTY1],

  0[ProductWeight],b.Price_struc [PriceCode],CONVERT(varchar,b.expiry,21) [BatchExpiryDate] ,sdd.PROJECT_CODE 
  from SCHEME_DISCOUNT_DETAIL sdd INNER JOIN T on sdd.company = t.company and sdd.DISTRIBUTOR = t.distributor 
  inner join scheme_discount sd on sdd.company = sd.company and sdd.distributor = sd.distributor and sdd.document = sd.document and sdd.sub_document = sd.sub_Document and sdd.doc_no = sd.doc_no 
  and sdd.mp_code = sd.mp_code and sdd.seq_id = sd.seq_id and sdd.serial_no = sd.serial_no inner JOIN SCHEME_TYPE ST ON ST.company = SD.company and ST.SCHEME_TYPE = SD.SCHEME_TYPE 
  INNER JOIN BATCH b on b.company = sd.company and b.sku = sdd.sku and b.batch = sdd.batch 
  
  UNION ALL select ss.COMPANY, ss.DISTRIBUTOR, ss.DOCUMENT, ss.SUB_DOCUMENT, ss.DOC_NO, '01' ENTRY_TYPE, 
  ss.SKU, '01' SKU_TYPE, ss.BATCH, '01' WAREHOUSE,0 REF_QTY1, 0 REF_QTY2, 0 REF_QTY3, 0 ORD_QTY1, 0 ORD_QTY2, 0 ORD_QTY3, ss.QTY1, ss.QTY2, ss.QTY3, ss.AMOUNT, ss.GST,abs(case when ss.amount = 0 then 0 
  else ss.GST/ss.AMOUNT end*100) GST_PERCENTAGE, null Ref_type, 1 FreeGoodsIndicator,ss.mp_code+ ss.seq_id PromotionID, 0 SDiscount, 0 TDiscount , isnull(st.LDESC,'') [PromotionType],'3' InvoiceType, 
  (ss.QTY1 * b.SELL_FACTOR1 + ss.QTY2 * b.SELL_FACTOR2 + ss.QTY3 * b.SELL_FACTOR3) QuantityDelivered,0 [QTY1],
  
  0 [QuantityDemanded],0[QuantityOrdered], (ss.QTY1 * b.SELL_WEIGHT1 + ss.QTY2 * b.SELL_WEIGHT2 + 
  ss.QTY3 * b.SELL_WEIGHT3)[ProductWeight],b.Price_struc [PriceCode],CONVERT(varchar,b.expiry,21) [BatchExpiryDate],''PROJECT_CODE from scheme_Sku ss INNER JOIN T on ss.company = t.company 
  and ss.DISTRIBUTOR = ss.distributor inner JOIN SCHEME_TYPE ST ON ST.company = ss.company and ST.SCHEME_TYPE = ss.SCHEME_TYPE INNER JOIN BATCH b on b.company = ss.company and b.sku = ss.sku 
  and b.batch = ss.batch ) CD 
  on CM.COMPANY = CD.COMPANY AND CM.DISTRIBUTOR = CD.DISTRIBUTOR AND CM.DOCUMENT = CD.DOCUMENT AND CM.SUB_DOCUMENT = CD.SUB_DOCUMENT AND CM.DOC_NO = CD.DOC_NO
WHERE  cm.company = T.company and  cm.distributor = T.distributor
  AND cm.VISIT_TYPE ='02' 
  and cm.DELV_DATE between'20250101' and '20250131'  
  ----/* and cm.IROW_VER >= T.FRV AND CM.IROW_VER < T.TRV*/ 
 
 --select * from #TEMP_SecondarySalesOut

--select distributor,[distributor name] Distributorname,sum(GrossAmount) GrossAmount ,sum(QuantityDelivered) 
--from #TEMP_SecondarySalesOut where promotionid='' group by distributor,[distributor name] order by 1


