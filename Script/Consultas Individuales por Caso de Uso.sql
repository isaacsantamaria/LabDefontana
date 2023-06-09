/* =========================================
 * Descrip: Sentencias de consultas individuales
 * Author : Isaac Santamaría
 * Cre.   : 08/06/2023
 * =========================================
 */
-- Bloque que contiene los registros de ventas de los últimos 30 días
WITH [datos] AS (
    SELECT 
      [V].ID_Venta, [V].Total, [V].Fecha, [V].ID_Local,
      [VD].ID_VentaDetalle, [VD].Precio_Unitario, [VD].Cantidad, [VD].TotalLinea, [VD].ID_Producto,
      [P].Nombre, [P].Codigo, [P].ID_Marca, [P].Modelo, [P].Costo_Unitario,
      [L].Nombre AS Local, [L].Direccion,
      [M].Nombre AS Marca
    FROM VentaDetalle [VD]
    INNER JOIN Venta [V] ON [VD].[ID_Venta] = [V].[ID_Venta]
    INNER JOIN Producto [P] ON [VD].[ID_Producto] = [P].[ID_Producto]
    INNER JOIN Local [L] ON [L].[ID_Local] = [V].[ID_Local]
    INNER JOIN Marca [M] ON [M].[ID_Marca] = [P].[ID_Marca]
    WHERE [V].Fecha >= DATEADD(DAY, -30, GETDATE())
)
-- Consulta del total de ventas en los últimos 30 días
SELECT 
    SUM([Total]) AS 'Monto Total de Ventas'
  , COUNT([ID_Venta]) AS 'Cantidad de Ventas'
  , (SUM([Total]) / COUNT([ID_Venta])) AS 'Promedio de Ventas'
FROM [datos];

-- Consulta de la venta más alta del período
SELECT TOP 1 
    [Total] AS 'Venta más Alta'
  , [Fecha] AS 'Fecha de la Venta más Alta'
FROM [datos]
ORDER BY [Total] DESC;

-- Consulta del producto con mayor monto total en ventas
SELECT TOP 1 
    Nombre AS 'Producto con la Venta más Alta'
  , MontoTotalVendido AS 'Monto Total del Producto con la Venta más Alta'
  , CantidadTotalVendida AS 'Monto Total del Producto con la Venta más Alta' 
FROM
(
  SELECT
      ID_Producto, 
      Nombre,
      SUM(TotalLinea) AS MontoTotalVendido,
      SUM(Cantidad) AS CantidadTotalVendida
  FROM datos
  GROUP BY ID_Producto, Nombre
) Resultado
ORDER BY MontoTotalVendido DESC, CantidadTotalVendida DESC;

-- Consulta del local con el mayor monto de ventas
SELECT TOP 1 
    Local AS 'Local con más Ventas'
  , MontoTotalVendido AS 'Monto Vendido del Local con más Ventas'
FROM
(
  SELECT
      ID_Local, 
      Local,
      SUM(Total) AS MontoTotalVendido
  FROM datos
  GROUP BY ID_Local, Local
) Resultado
ORDER BY MontoTotalVendido DESC

-- Consulta de la marca con mayor ganancia
SELECT TOP 1 
    Marca AS 'Marca con Mayor Ganancia'
  , MontoGanancia AS 'Monto de Ganancia de la Marca de Mayor Ganancia'
FROM
(
  SELECT
    Marca,
    SUM(Precio_Unitario) - SUM(Costo_Unitario) AS MontoGanancia
  FROM datos
  GROUP BY Marca
) Resultado
ORDER BY MontoGanancia DESC

-- Consulta del producto de mayor venta por local
SELECT LM.Nombre AS 'Local', PML.ID_Producto AS 'Código Producto', PML.TotalVendido, P.Nombre AS 'Nombre Producto'
FROM (
    SELECT ID_Local, ID_Producto, SUM(TotalLinea) AS TotalVendido, ROW_NUMBER() OVER (PARTITION BY ID_Local ORDER BY SUM(TotalLinea) DESC) AS RowNum
    FROM datos
    GROUP BY ID_Local, ID_Producto
) AS PML
INNER JOIN (
    SELECT VPL.ID_Local, MAX(TotalVendido) AS MaxTotalVendido
    FROM (
      SELECT ID_Local, SUM(TotalLinea) AS TotalVendido
      FROM datos
        GROUP BY ID_Local
    ) AS VPL
    GROUP BY VPL.ID_Local
) AS MaxVendido ON PML.ID_Local = MaxVendido.ID_Local --AND PML.TotalVendido = MaxVendido.MaxTotalVendido
INNER JOIN Local AS LM ON PML.ID_Local = LM.ID_Local
INNER JOIN Producto AS P ON PML.ID_Producto = P.ID_Producto
WHERE PML.RowNum = 1
ORDER BY TotalVendido DESC;

/**** EL ENFOQUE CON TABLA WITH NO FUNCIONA EN ESTE CASO PARA MÁS DE UNA CONSULTA SELECT POR UN TEMA DE VERSIONES DE SQL SERVER POR LO QUE SE USAN INSTRUCCIONES INDIVIDUALES ****/
/**** TAMBIEN SE PUDO USAR EL ENFOQUE EN TABLA TEMPORAL PERO POR TEMAS DE TIEMPO SE REALIZARON CONSULTAS INDIVIDUALES ****/

-- Consulta del total de ventas en los últimos 30 días
SELECT 
    SUM([Total]) AS 'Monto Total de Ventas'
  , COUNT([ID_Venta]) AS 'Cantidad de Ventas'
  , (SUM([Total]) / COUNT([ID_Venta])) AS 'Promedio de Ventas'
FROM
(
  SELECT 
      [V].ID_Venta, [V].Total, [V].Fecha, [V].ID_Local,
      [VD].ID_VentaDetalle, [VD].Precio_Unitario, [VD].Cantidad, [VD].TotalLinea, [VD].ID_Producto,
      [P].Nombre, [P].Codigo, [P].ID_Marca, [P].Modelo, [P].Costo_Unitario,
      [L].Nombre AS Local, [L].Direccion,
      [M].Nombre AS Marca
    FROM VentaDetalle [VD]
    INNER JOIN Venta [V] ON [VD].[ID_Venta] = [V].[ID_Venta]
    INNER JOIN Producto [P] ON [VD].[ID_Producto] = [P].[ID_Producto]
    INNER JOIN Local [L] ON [L].[ID_Local] = [V].[ID_Local]
    INNER JOIN Marca [M] ON [M].[ID_Marca] = [P].[ID_Marca]
    WHERE [V].Fecha >= DATEADD(DAY, -30, GETDATE())
) datos;

-- Consulta de la venta más alta del período
SELECT TOP 1 
    [Total] AS 'Venta más Alta'
  , [Fecha] AS 'Fecha de la Venta más Alta'
FROM
(
  SELECT 
      [V].ID_Venta, [V].Total, [V].Fecha, [V].ID_Local,
      [VD].ID_VentaDetalle, [VD].Precio_Unitario, [VD].Cantidad, [VD].TotalLinea, [VD].ID_Producto,
      [P].Nombre, [P].Codigo, [P].ID_Marca, [P].Modelo, [P].Costo_Unitario,
      [L].Nombre AS Local, [L].Direccion,
      [M].Nombre AS Marca
    FROM VentaDetalle [VD]
    INNER JOIN Venta [V] ON [VD].[ID_Venta] = [V].[ID_Venta]
    INNER JOIN Producto [P] ON [VD].[ID_Producto] = [P].[ID_Producto]
    INNER JOIN Local [L] ON [L].[ID_Local] = [V].[ID_Local]
    INNER JOIN Marca [M] ON [M].[ID_Marca] = [P].[ID_Marca]
    WHERE [V].Fecha >= DATEADD(DAY, -30, GETDATE())
) datos
ORDER BY [Total] DESC;

-- Consulta del producto con mayor monto total en ventas
SELECT TOP 1 
    Nombre AS 'Producto con la Venta más Alta'
  , MontoTotalVendido AS 'Monto Total del Producto con la Venta más Alta'
  , CantidadTotalVendida AS 'Monto Total del Producto con la Venta más Alta' 
FROM
(
  SELECT
      ID_Producto, 
      Nombre,
      SUM(TotalLinea) AS MontoTotalVendido,
      SUM(Cantidad) AS CantidadTotalVendida
  FROM
  (
    SELECT 
      [V].ID_Venta, [V].Total, [V].Fecha, [V].ID_Local,
      [VD].ID_VentaDetalle, [VD].Precio_Unitario, [VD].Cantidad, [VD].TotalLinea, [VD].ID_Producto,
      [P].Nombre, [P].Codigo, [P].ID_Marca, [P].Modelo, [P].Costo_Unitario,
      [L].Nombre AS Local, [L].Direccion,
      [M].Nombre AS Marca
    FROM VentaDetalle [VD]
    INNER JOIN Venta [V] ON [VD].[ID_Venta] = [V].[ID_Venta]
    INNER JOIN Producto [P] ON [VD].[ID_Producto] = [P].[ID_Producto]
    INNER JOIN Local [L] ON [L].[ID_Local] = [V].[ID_Local]
    INNER JOIN Marca [M] ON [M].[ID_Marca] = [P].[ID_Marca]
    WHERE [V].Fecha >= DATEADD(DAY, -30, GETDATE())
  ) datos
  GROUP BY ID_Producto, Nombre
) Resultado
ORDER BY MontoTotalVendido DESC, CantidadTotalVendida DESC;

-- Consulta del local con el mayor monto de ventas
SELECT TOP 1 
    Local AS 'Local con más Ventas'
  , MontoTotalVendido AS 'Monto Vendido del Local con más Ventas'
FROM
(
  SELECT
      ID_Local, 
      Local,
      SUM(Total) AS MontoTotalVendido
  FROM
  (
    SELECT 
      [V].ID_Venta, [V].Total, [V].Fecha, [V].ID_Local,
      [VD].ID_VentaDetalle, [VD].Precio_Unitario, [VD].Cantidad, [VD].TotalLinea, [VD].ID_Producto,
      [P].Nombre, [P].Codigo, [P].ID_Marca, [P].Modelo, [P].Costo_Unitario,
      [L].Nombre AS Local, [L].Direccion,
      [M].Nombre AS Marca
    FROM VentaDetalle [VD]
    INNER JOIN Venta [V] ON [VD].[ID_Venta] = [V].[ID_Venta]
    INNER JOIN Producto [P] ON [VD].[ID_Producto] = [P].[ID_Producto]
    INNER JOIN Local [L] ON [L].[ID_Local] = [V].[ID_Local]
    INNER JOIN Marca [M] ON [M].[ID_Marca] = [P].[ID_Marca]
    WHERE [V].Fecha >= DATEADD(DAY, -30, GETDATE())
  ) datos
  GROUP BY ID_Local, Local
) Resultado
ORDER BY MontoTotalVendido DESC

-- Consulta de la marca con mayor ganancia
SELECT TOP 1 
    Marca AS 'Marca con Mayor Ganancia'
  , MontoGanancia AS 'Monto de Ganancia de la Marca de Mayor Ganancia'
FROM
(
  SELECT
    Marca,
    SUM(Precio_Unitario) - SUM(Costo_Unitario) AS MontoGanancia
  FROM
  (
    SELECT 
      [V].ID_Venta, [V].Total, [V].Fecha, [V].ID_Local,
      [VD].ID_VentaDetalle, [VD].Precio_Unitario, [VD].Cantidad, [VD].TotalLinea, [VD].ID_Producto,
      [P].Nombre, [P].Codigo, [P].ID_Marca, [P].Modelo, [P].Costo_Unitario,
      [L].Nombre AS Local, [L].Direccion,
      [M].Nombre AS Marca
    FROM VentaDetalle [VD]
    INNER JOIN Venta [V] ON [VD].[ID_Venta] = [V].[ID_Venta]
    INNER JOIN Producto [P] ON [VD].[ID_Producto] = [P].[ID_Producto]
    INNER JOIN Local [L] ON [L].[ID_Local] = [V].[ID_Local]
    INNER JOIN Marca [M] ON [M].[ID_Marca] = [P].[ID_Marca]
    WHERE [V].Fecha >= DATEADD(DAY, -30, GETDATE())
  ) datos
  GROUP BY Marca
) Resultado
ORDER BY MontoGanancia DESC

-- Consulta del producto de mayor venta por local
SELECT LM.Nombre AS 'Local', PML.ID_Producto AS 'Código Producto', PML.TotalVendido, P.Nombre AS 'Nombre Producto'
FROM (
    SELECT ID_Local, ID_Producto, SUM(TotalLinea) AS TotalVendido, ROW_NUMBER() OVER (PARTITION BY ID_Local ORDER BY SUM(TotalLinea) DESC) AS RowNum
    FROM (
      SELECT 
        [V].ID_Venta, [V].Total, [V].Fecha, [V].ID_Local,
        [VD].ID_VentaDetalle, [VD].Precio_Unitario, [VD].Cantidad, [VD].TotalLinea, [VD].ID_Producto,
        [P].Nombre, [P].Codigo, [P].ID_Marca, [P].Modelo, [P].Costo_Unitario,
        [L].Nombre AS Local, [L].Direccion,
        [M].Nombre AS Marca
      FROM VentaDetalle [VD]
      INNER JOIN Venta [V] ON [VD].[ID_Venta] = [V].[ID_Venta]
      INNER JOIN Producto [P] ON [VD].[ID_Producto] = [P].[ID_Producto]
      INNER JOIN Local [L] ON [L].[ID_Local] = [V].[ID_Local]
      INNER JOIN Marca [M] ON [M].[ID_Marca] = [P].[ID_Marca]
      WHERE [V].Fecha >= DATEADD(DAY, -30, GETDATE())
    ) AS datos
    GROUP BY ID_Local, ID_Producto
) AS PML
INNER JOIN (
    SELECT VPL.ID_Local, MAX(TotalVendido) AS MaxTotalVendido
    FROM (
      SELECT ID_Local, SUM(TotalLinea) AS TotalVendido
      FROM ( 
          SELECT 
            [V].ID_Venta, [V].Total, [V].Fecha, [V].ID_Local,
            [VD].ID_VentaDetalle, [VD].Precio_Unitario, [VD].Cantidad, [VD].TotalLinea, [VD].ID_Producto,
            [P].Nombre, [P].Codigo, [P].ID_Marca, [P].Modelo, [P].Costo_Unitario,
            [L].Nombre AS Local, [L].Direccion,
            [M].Nombre AS Marca
          FROM VentaDetalle [VD]
          INNER JOIN Venta [V] ON [VD].[ID_Venta] = [V].[ID_Venta]
          INNER JOIN Producto [P] ON [VD].[ID_Producto] = [P].[ID_Producto]
          INNER JOIN Local [L] ON [L].[ID_Local] = [V].[ID_Local]
          INNER JOIN Marca [M] ON [M].[ID_Marca] = [P].[ID_Marca]
          WHERE [V].Fecha >= DATEADD(DAY, -30, GETDATE())
        ) AS datos
        GROUP BY ID_Local
    ) AS VPL
    GROUP BY VPL.ID_Local
) AS MaxVendido ON PML.ID_Local = MaxVendido.ID_Local --AND PML.TotalVendido = MaxVendido.MaxTotalVendido
INNER JOIN Local AS LM ON PML.ID_Local = LM.ID_Local
INNER JOIN Producto AS P ON PML.ID_Producto = P.ID_Producto
WHERE PML.RowNum = 1
ORDER BY TotalVendido DESC;