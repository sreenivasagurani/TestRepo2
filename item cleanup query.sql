  SELECT   ITEM,
           DESCRIPTION,
           PRIMARY_UNIT_OF_MEASURE,
           MAX (
              DISTINCT CASE
                          WHEN CATEGORY_SET = 'OPM Cost Class' THEN CATEGORY
                       END
           )
              AS "OPM Cost Class",
           MAX (
              DISTINCT CASE
                          WHEN CATEGORY_SET = 'OPM GL Business Class'
                          THEN
                             CATEGORY
                       END
           )
              AS "OPM GL Business Class",
           MAX (
              DISTINCT CASE
                          WHEN CATEGORY_SET = 'OPM GL Item Class' THEN CATEGORY
                       END
           )
              AS "OPM GL Item Class",
           ITEM_STATUS,
           JDW_ORG,
           LAST_TRANSACTION_DATE,
           COUNT ( * ) AS NWQ_AGG_SET_COUNT_SPECIAL_COL
    FROM   (SELECT   msib.segment1 Item,
                     msib.description,
                     mcv.CATEGORY_SET_NAME category_set,
                     mcv.CONTROL_LEVEL_DISP control_level,
                     mcv.CATEGORY_CONCAT_SEGS category,
                     (SELECT   organization_code
                        FROM   apps.org_organization_definitions
                       WHERE   organization_id = msib.organization_id)
                        organization_code,
                     INVENTORY_ITEM_STATUS_CODE ITEM_STATUS,
                     PRIMARY_UNIT_OF_MEASURE,
                     (select 'JDW' from mtl_system_items_b a  where a.segment1 = msib.segment1 and
organization_id =1524) JDW_ORG,
(select to_char( max(transaction_date) , 'MON-YYYY')  from mtl_material_transactions where  INVENTORY_ITEM_ID = msib.INVENTORY_ITEM_ID) LAST_TRANSACTION_DATE
              FROM   apps.mtl_item_categories mic,
                     apps.mtl_system_items_b msib,
                     apps.MTL_ITEM_CATEGORIES_V mcv
             WHERE       msib.inventory_item_id = mic.inventory_item_id
                     AND msib.organization_id = mic.organization_id
                     AND mic.organization_id = mcv.organization_id
                     AND mcv.inventory_item_id = mic.inventory_item_id
                     AND mcv.category_id = mic.category_id
                     AND msib.organization_id=81)
 /* WHERE  ( (ITEM NOT LIKE '%-%')
            AND (SUBSTR (ITEM, 1, 1) IN
                       ('1', '2', '3', '4', '5', '6', '7', '8', '9', 'N', 'P','M'))
            AND (ITEM NOT LIKE '%.%')
            AND (ITEM NOT LIKE '%/%')
            AND (ITEM NOT LIKE '%" "%')
            AND (ITEM NOT LIKE '%,%')
            AND (ITEM NOT LIKE '%#%')
           AND (ORGANIZATION_CODE = 'JDR')   )  */
GROUP BY   ITEM,
           DESCRIPTION,
           PRIMARY_UNIT_OF_MEASURE,
           ITEM_STATUS,
           JDW_ORG,LAST_TRANSACTION_DATE
ORDER BY   ITEM ASC

==================================================================
--Beverage Formula



/* Formatted on 5/21/2018 9:57:26 AM (QP5 v5.115.810.9015) */
  SELECT   SUBSTR (GR.Recipe_Number, 1, 3) AS Org,
           GR.Item$SV$Roll_Sku AS Product,
           GR.Formula_Version AS ""Formula Version"",
           MAX (GR.Formula_Number) AS ""Formula Number"",
           GF.Line_Type AS ""Line Type"",
           GF.Item$SV$Roll_Sku AS ""Item Number"",
           GF.Item_Description AS "" Item Description "",
           (SELECT   'JDW'
              FROM   INVG0_Items a
             WHERE   a.Item$SV$Roll_Sku = gf.Item$SV$Roll_Sku
                     AND ITEM$ORGANIZATION_ID = 1524)
              --           CASE
              --              WHEN a.Item$SV$Roll_Sku = gf.Item$SV$Roll_Sku
              --                   AND a.Item$Organization_Id = 1524
              --              THEN
              --                 'JDW'
              --              ELSE
              --                 NULL
              --           END
              JDW_ORG,
           GF.Item_Quantity AS Quantity,
           GF.Item_UOM AS UOM,
           GF.Formula_Status,
           COUNT ( * ) AS NWQ_AGG_SET_COUNT_SPECIAL_COL
    FROM   GMDG0_Recipes GR, GMDG0_Recipe_Validity_Rules GVR, GMDG0_Formulas GF
   WHERE       GR.Z$GMDG0_Recipes = GVR.Z$GMDG0_Recipes
           AND GF.Z$GMDG0_Formulas = GR.Z$GMDG0_Formulas
           --            AND ( (SUBSTR (GR.Recipe_Number, 1, 3) IN
           --                        ('JBL', 'JBT', 'JDR', 'OSP', 'PBM'))
           --                AND (GVR.Validity_Rule_Status IN
           --                           ('Frozen', 'Approved for General Use'))
           AND (GVR.Validity_Rule_End_Date IS NULL)
           AND (GVR.Recipe_Use <> 'Costing')
GROUP BY   SUBSTR (GR.Recipe_Number, 1, 3),
           GR.Item$SV$Roll_Sku,
           GR.Formula_Version,
           GF.Line_Type,
           GF.Item$SV$Roll_Sku,
           GF.Item_Description,
           GF.Item_Quantity,
           GF.Item_UOM,
           GF.Formula_Status
===================================
fresh BOM


/* Formatted on 5/22/2018 11:08:15 AM (QP5 v5.115.810.9015) */
  SELECT   MAX (DISTINCT ASSY$ROLL_SKU),
           (SELECT   'JDW'
              FROM   apps.mtl_system_items_b a
             WHERE   a.segment1 = ASSY$ROLL_SKU AND organization_id = 1524)
              JDW_ORG,
           Assembly_Description,
           COMP$ROLL_SKU,
           Component_Description,
           Component_Item_Type,
           Component_Total_Quantity,
           Component_Totaled_Cost,
           Component_Unit_Cost,
           Component_Unit_Of_Measure,
           Assembly_Revision_Date,
           Assembly_Status,
           Assembly_Unit_Of_Measure,
           COUNT ( * ) AS NWQ_AGG_SET_COUNT_SPECIAL_COL
    FROM   BOM4_Current_Summary
   WHERE   (   (ASSY$ROLL_SKU LIKE 'P%')
            OR (ASSY$ROLL_SKU LIKE 'MA%')
            OR (ASSY$ROLL_SKU LIKE 'MM%'))
GROUP BY   Assembly_Description,
           ASSY$ROLL_SKU,
           COMP$ROLL_SKU,
           Component_Description,
           Component_Item_Type,
           Component_Total_Quantity,
           Component_Totaled_Cost,
           Component_Unit_Cost,
           Component_Unit_Of_Measure,
           Assembly_Revision_Date,
           Assembly_Status,
           Assembly_Unit_Of_Measure