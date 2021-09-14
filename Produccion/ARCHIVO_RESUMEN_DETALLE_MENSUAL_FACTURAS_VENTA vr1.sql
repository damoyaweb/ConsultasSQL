use GlobalWine



select 
'Sequence No.' ,
'Record Type' ,
'Depletion Period',
'Distributor Code',
'Account Code',
'Premise Type',
'Distributor SKU',
'Distributor Brand Code',
'Distributor Brand Name',
'Shipped Qty Case',
'Shipped Qty Bottle',
'Extended List Price',
'Excise / Muicipal Tax',
'VAT',
'Discount Type',
'Extended Discount - On Invoce',
'Extended Discount - Off Invoce',
'Currency',
'Extended Net Selling Price'--,
--'Documento'

UNION ALL

--FACTURAS PROVEEDOR
--------------------------------------------------------------------------------------

SELECT distinct
convert(varchar(max), ROW_NUMBER() OVER(ORDER BY T2.CardCode ASC)) AS 'Sequence No.' ,
convert(varchar(max),'2') as 'Record Type' ,
CONVERT(varchar(6),  T0.[RefDate], 112) as 'Depletion Period',
convert(varchar(max),'0002006264') as 'Distributor Code',
T2.CardCode as 'Account Code',
CASE 
WHEN T1.[OcrCode2]='02' THEN 'O'
WHEN T1.[OcrCode2]='99' THEN 'H'
ELSE 'F' END AS 'Premise Type',
'' as 'Distributor SKU',
convert(varchar(max),T1.[ProfitCode]) as 'Distributor Brand Code',
T3.PrcName as 'Distributor Brand Name',
'' as 'Shipped Qty Case',
'' as 'Shipped Qty Bottle',
'' as 'Extended List Price',
'' as 'Excise / Muicipal Tax',
'' as 'VAT',
T4.AcctName as 'Discount Type',

CASE 
WHEN T1.[OcrCode2]='02' THEN convert(varchar(max),(T1.[Debit]*(100*(t2.VatSum/((t2.DocTotal)+(t2.WtSum)-t2.VatSum)))/100)+T1.[Debit])
ELSE '0' END as 'Extended Discount - On Invoce',

CASE 
WHEN T1.[OcrCode2]='02' THEN '0'                    
ELSE convert(varchar(max),(T1.[Debit]*100*(t2.VatSum/((t2.DocTotal)+(t2.WtSum)-t2.VatSum))/100)+T1.[Debit])      
END as 'Extended Discount - Off Invoce',

case 
when T2.DOCCUR='$' then 'COP'
ELSE T2.DOCCUR END as 'Currency',
'' AS 'Extended Net Selling Price'--,
--convert(varchar(max),t2.DocNum)
 
 FROM  OJDT T0 
 INNER JOIN JDT1 T1 ON T0.TransId = T1.TransId 
 INNER JOIN OPCH T2 ON T0.TransId = T2.TransId
 INNER JOIN OPRC T3 ON T1.ProfitCode = T3.PrcCode
 INNER JOIN OACT T4 ON T1.Account=T4.AcctCode
 where T0.[RefDate]>='20210801' and T0.[RefDate]<='20210831'
 and T1.[OcrCode3]='005'
-- and t2.DocNum='40883'


union all

--NOTAS CREDITO PROVEEDOR
SELECT distinct
convert(varchar(max), ROW_NUMBER() OVER(ORDER BY T2.CardCode ASC)) AS 'Sequence No.' ,
convert(varchar(max),'2') as 'Record Type' ,
CONVERT(varchar(6),  T0.[RefDate], 112) as 'Depletion Period',
convert(varchar(max),'0002006264') as 'Distributor Code',
T2.CardCode as 'Account Code',
CASE 
WHEN T1.[OcrCode2]='02' THEN 'O'
WHEN T1.[OcrCode2]='99' THEN 'H'
ELSE 'F' END AS 'Premise Type',
'' as 'Distributor SKU',
convert(varchar(max),T1.[ProfitCode]) as 'Distributor Brand Code',
T3.PrcName as 'Distributor Brand Name',
'' as 'Shipped Qty Case',
'' as 'Shipped Qty Bottle',
'' as 'Extended List Price',
'' as 'Excise / Muicipal Tax',
'' as 'VAT',
T4.AcctName as 'Discount Type',
--CON RETENCION
--CASE 
--WHEN T1.[OcrCode2]='02' THEN convert(varchar(max),((T1.[Credit]*(100*(t2.VatSum/((t2.DocTotal)+(t2.WtSum)-t2.VatSum)))/100)+(T1.[Credit])-T2.[WtSum])*-1)
--ELSE '0' END as 'Extended Discount - On Invoce',

--CASE 
--WHEN T1.[OcrCode2]='02' THEN '0'                    
--ELSE convert(varchar(max),((T1.[Credit]*(100*(t2.VatSum/((t2.DocTotal)+(t2.WtSum)-t2.VatSum)))/100)+(T1.[Credit])-T2.[WtSum])*-1)      
--END as 'Extended Discount - Off Invoce',

--SIN RETENCION
CASE 
WHEN T1.[OcrCode2]='02' THEN convert(varchar(max),((T1.[Credit]*(100*(t2.VatSum/((t2.DocTotal)+(t2.WtSum)-t2.VatSum)))/100)+T1.[Credit])*-1)
ELSE '0' END as 'Extended Discount - On Invoce',

CASE 
WHEN T1.[OcrCode2]='02' THEN '0'                    
ELSE convert(varchar(max),((T1.[Credit]*(100*(t2.VatSum/((t2.DocTotal)+(t2.WtSum)-t2.VatSum)))/100)+T1.[Credit])*-1)      
END as 'Extended Discount - Off Invoce',

case 
when T2.DOCCUR='$' then 'COP'
ELSE T2.DOCCUR END as 'Currency',
'' AS 'Extended Net Selling Price'--,
--convert(varchar(max),t2.DocNum)

 FROM  OJDT T0 
 INNER JOIN JDT1 T1 ON T0.TransId = T1.TransId 
 INNER JOIN ORPC T2 ON T0.TransId = T2.TransId
 INNER JOIN OPRC T3 ON T1.ProfitCode = T3.PrcCode
 INNER JOIN OACT T4 ON T1.Account=T4.AcctCode
 where T0.[RefDate]>='20210801' and T0.[RefDate]<='20210831'
 and T1.[OcrCode3]='005'
 --AND  t2.DocNum='3137'

 union all
 ---------------------------------------------------------------------------------------------------
 --ASIENTOS CONTABLES
--DEBITOS POSITIVOS ++

SELECT distinct
convert(varchar(max), ROW_NUMBER() OVER(ORDER BY T1.[U_HBT_Tercero] ASC)) AS 'Sequence No.' ,
convert(varchar(max),'2') as 'Record Type' ,
CONVERT(varchar(6),  T0.[RefDate], 112) as 'Depletion Period',
convert(varchar(max),'0002006264') as 'Distributor Code',
T2.CardCode as 'Account Code',
CASE 
WHEN T1.[OcrCode2]='02' THEN 'O'
WHEN T1.[OcrCode2]='99' THEN 'H'
ELSE 'F' END AS 'Premise Type',
'' as 'Distributor SKU',
convert(varchar(max),T1.[ProfitCode]) as 'Distributor Brand Code',
T3.PrcName as 'Distributor Brand Name',
'' as 'Shipped Qty Case',
'' as 'Shipped Qty Bottle',
'' as 'Extended List Price',
'' as 'Excise / Muicipal Tax',
'' as 'VAT',
T4.AcctName as 'Discount Type',
CASE 
WHEN T1.[OcrCode2]='02' THEN convert(varchar(max),T1.[Debit])
ELSE '0' END as 'Extended Discount - On Invoce',

CASE 
WHEN T1.[OcrCode2]='02' THEN '0'                    
ELSE convert(varchar(max),T1.[Debit])      
END as 'Extended Discount - Off Invoce',
'COP' as 'Currency',
'' AS 'Extended Net Selling Price'--,
--case 
--when T2.DOCCUR='$' then 'COP'
--ELSE T2.DOCCUR END as 'Currency',
--'' AS 'Extended Net Selling Price',
--convert(varchar(max),t2.DocNum)


FROM OJDT T0 
INNER JOIN JDT1 T1 ON T0.TransId = T1.TransId  
LEFT JOIN OCRD T2 ON T1.[U_HBT_Tercero] =T2.CardCode
INNER JOIN OPRC T3 ON T1.ProfitCode = T3.PrcCode
INNER JOIN OACT T4 ON T1.Account=T4.AcctCode
 

where T1.[OcrCode3]='005' and T0.[RefDate]>='20210801' and T0.[RefDate]<='20210831' and
t1.Account in ('13802515', '13802516', '41751410', '52201010', '52209510', '52356005', '52356010', '52356015', '52356020', '52356025', '52356030', '52356035', '52356040', '52356095', '52356096')
and t1.TransType in ('13', '14', '30', '59', '60') and T1.[Debit]>0

UNION ALL

--CREDITOS NEGATIVOS -

SELECT distinct
convert(varchar(max), ROW_NUMBER() OVER(ORDER BY T1.[U_HBT_Tercero] ASC)) AS 'Sequence No.' ,
convert(varchar(max),'2') as 'Record Type' ,
CONVERT(varchar(6),  T0.[RefDate], 112) as 'Depletion Period',
convert(varchar(max),'0002006264') as 'Distributor Code',
T2.CardCode as 'Account Code',
CASE 
WHEN T1.[OcrCode2]='02' THEN 'O'
WHEN T1.[OcrCode2]='99' THEN 'H'
ELSE 'F' END AS 'Premise Type',
'' as 'Distributor SKU',
convert(varchar(max),T1.[ProfitCode]) as 'Distributor Brand Code',
T3.PrcName as 'Distributor Brand Name',
'' as 'Shipped Qty Case',
'' as 'Shipped Qty Bottle',
'' as 'Extended List Price',
'' as 'Excise / Muicipal Tax',
'' as 'VAT',
T4.AcctName as 'Discount Type',
CASE 
WHEN T1.[OcrCode2]='02' THEN convert(varchar(max),T1.[Credit]*-1)
ELSE '0' END as 'Extended Discount - On Invoce',

CASE 
WHEN T1.[OcrCode2]='02' THEN '0'                    
ELSE convert(varchar(max),T1.[Credit]*-1)      
END as 'Extended Discount - Off Invoce',
'COP'as 'Currency',
'' AS 'Extended Net Selling Price'--,
--case 
--when T2.DOCCUR='$' then 'COP'
--ELSE T2.DOCCUR END as 'Currency',
--'' AS 'Extended Net Selling Price',
--convert(varchar(max),t2.DocNum)


FROM OJDT T0 
INNER JOIN JDT1 T1 ON T0.TransId = T1.TransId  
LEFT JOIN OCRD T2 ON T1.[U_HBT_Tercero] =T2.CardCode
INNER JOIN OPRC T3 ON T1.ProfitCode = T3.PrcCode
INNER JOIN OACT T4 ON T1.Account=T4.AcctCode
 

where T1.[OcrCode3]='005' and T0.[RefDate]>='20210801' and T0.[RefDate]<='20210831' and
t1.Account in ('13802515', '13802516', '41751410', '52201010', '52209510', '52356005', '52356010', '52356015', '52356020', '52356025', '52356030', '52356035', '52356040', '52356095', '52356096')
and t1.TransType in ('13', '14', '30', '59', '60') and T1.[Credit]>0

UNION ALL
-----------------------------------------------------------
--SALIDAS FREEGODS
-----
SELECT distinct
convert(varchar(max), ROW_NUMBER() OVER(ORDER BY T1.[U_GW_CLIENTE] ASC)) AS 'Sequence No.' ,
convert(varchar(max),'2') as 'Record Type' ,
CONVERT(varchar(6),  T0.[DocDate], 112) as 'Depletion Period',
convert(varchar(max),'0002006264') as 'Distributor Code',
T1.U_GW_CLIENTE AS 'Account Code',
CASE 
WHEN T1.[OcrCode2]='02' THEN 'O'
WHEN T1.[OcrCode2]='99' THEN 'H'
ELSE 'F' END AS 'Premise Type',
'' as 'Distributor SKU',
convert(varchar(max),T1.[OcrCode]) as 'Distributor Brand Code',
T12.PrcName as 'Distributor Brand Name',
'' as 'Shipped Qty Case',
'' as 'Shipped Qty Bottle',
'' as 'Extended List Price',
'' as 'Excise / Muicipal Tax',
'' as 'VAT',
T13.AcctName as 'Discount Type',

--(Costo del producto + ( % iva precio lista distribuidores) + ICO)) Cantidad

CASE 
WHEN T1.[OcrCode2]='02' THEN convert(varchar(max),((((T14.Price*T15.Rate)/100)+T1.[StockPrice])*T1.[Quantity])+(T4.[U_GW_ICO]*T1.[Quantity]))
ELSE '0' END as 'Extended Discount - On Invoce',

CASE 
WHEN T1.[OcrCode2]='02' THEN '0'                    
ELSE convert(varchar(max),((((T14.Price*T15.Rate)/100)+T1.[StockPrice])*T1.[Quantity])+(T4.[U_GW_ICO]*T1.[Quantity]))
END as 'Extended Discount - Off Invoce',
'COP'as 'Currency',
'' AS 'Extended Net Selling Price'
FROM OIGE T0  
INNER JOIN IGE1 T1 ON T0.DocEntry = T1.DocEntry    
INNER JOIN OITM T4 ON T1.ItemCode = T4.ItemCode 
INNER JOIN OPRC T12 ON T1.OcrCode = T12.PrcCode
INNER JOIN OACT T13 ON T1.AcctCode=T13.AcctCode
INNER JOIN ITM1 T14 ON T1.ItemCode=T14.ItemCode
INNER JOIN OSTC T15 ON T4.TaxCodeAR=T15.Code
WHERE 
T0.[DocDate]>='20210801' AND T0.[DocDate]<='20210831' 
and T1.[OcrCode3]='005' AND T14.PriceList=7

union all

--ENTRADAS DE MERCANCIA

SELECT distinct
convert(varchar(max), ROW_NUMBER() OVER(ORDER BY T1.[U_GW_CLIENTE] ASC)) AS 'Sequence No.' ,
convert(varchar(max),'2') as 'Record Type' ,
CONVERT(varchar(6),  T0.[DocDate], 112) as 'Depletion Period',
convert(varchar(max),'0002006264') as 'Distributor Code',
T1.U_GW_CLIENTE AS 'Account Code',
CASE 
WHEN T1.[OcrCode2]='02' THEN 'O'
WHEN T1.[OcrCode2]='99' THEN 'H'
ELSE 'F' END AS 'Premise Type',
'' as 'Distributor SKU',
convert(varchar(max),T1.[OcrCode]) as 'Distributor Brand Code',
T12.PrcName as 'Distributor Brand Name',
'' as 'Shipped Qty Case',
'' as 'Shipped Qty Bottle',
'' as 'Extended List Price',
'' as 'Excise / Muicipal Tax',
'' as 'VAT',
T13.AcctName as 'Discount Type',

CASE 
WHEN T1.[OcrCode2]='02' THEN convert(varchar(max),-(((((T14.Price*T15.Rate)/100)+T1.[StockPrice])*T1.[Quantity])+(T4.[U_GW_ICO]*T1.[Quantity])))
ELSE '0' END as 'Extended Discount - On Invoce',

CASE 
WHEN T1.[OcrCode2]='02' THEN '0'                    
ELSE convert(varchar(max),-(((((T14.Price*T15.Rate)/100)+T1.[StockPrice])*T1.[Quantity])+(T4.[U_GW_ICO]*T1.[Quantity])))
END as 'Extended Discount - Off Invoce',
'COP'as 'Currency',
'' AS 'Extended Net Selling Price'


FROM OIGN T0  
INNER JOIN IGN1 T1 ON T0.DocEntry = T1.DocEntry    
INNER JOIN OITM T4 ON T1.ItemCode = T4.ItemCode 
INNER JOIN OPRC T12 ON T1.OcrCode = T12.PrcCode
INNER JOIN OACT T13 ON T1.AcctCode=T13.AcctCode
INNER JOIN ITM1 T14 ON T1.ItemCode=T14.ItemCode
INNER JOIN OSTC T15 ON T4.TaxCodeAR=T15.Code
WHERE 
T0.[DocDate]>='20210801' AND T0.[DocDate]<='20210831' 
and T1.[OcrCode3]='005' AND T14.PriceList=7
