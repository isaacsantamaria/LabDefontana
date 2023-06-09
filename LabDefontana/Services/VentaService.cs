using LabDefontana.Data;
using LabDefontana.Repository.Interfaces;
using LabDefontana.Services.Interfaces;
using LabDefontana.ViewModels;
using Microsoft.EntityFrameworkCore;

namespace LabDefontana.Services
{
    public class VentasService : IVentasService
    {
        private readonly ApplicationDbContext _context;
        private readonly IVentaRepository _ventaRepository;

        public VentasService(ApplicationDbContext context, IVentaRepository ventaRepository)
        {
            _context = context;
            _ventaRepository = ventaRepository;
        }

        public async Task<VentaViewModel> ConsultaDetalleVentas()
        {
            var resultado = new VentaViewModel();

            try
            {
                // Registros de ventas de los últimos 30 días
                var datos = _ventaRepository.ObtenerVentasDetalles(30);

                //  Promedio, cantidad y total de ventas
                resultado.TotalVentas = datos.Sum(x => x.IdVentaNavigation.Total);
                resultado.CantidadVentas = await datos.Select(x => x.IdVenta).CountAsync();

                if (resultado.CantidadVentas > 0)
                    resultado.PromedioVentas = resultado.TotalVentas / resultado.CantidadVentas;

                //  Fecha y monto de mayor venta
                resultado.FechaVentaMayor = await datos.OrderByDescending(x => x.IdVentaNavigation.Total)
                    .Select(x => x.IdVentaNavigation.Fecha)
                    .FirstOrDefaultAsync();

                resultado.MontoVentaMayor = datos.Max(x => x.IdVentaNavigation.Total);

                //  Producto más vendido
                var productoMasVendido = await datos
                    .GroupBy(x => x.IdProducto)
                    .Select(g => new
                    {
                        CodigoProducto = g.Key,
                        MontoTotalVendido = g.Sum(x => x.TotalLinea),
                        CantidadTotalVendida = g.Sum(x => x.Cantidad),
                    })
                    .OrderByDescending(x => x.MontoTotalVendido)
                    .ThenByDescending(x => x.CantidadTotalVendida)
                    .FirstOrDefaultAsync();

                if (productoMasVendido != null)
                {
                    var producto = await datos
                        .FirstOrDefaultAsync(p => p.IdProducto == productoMasVendido.CodigoProducto);

                    if (producto != null)
                    {
                        resultado.ProductoMasVendido = producto.IdProductoNavigation.Nombre;
                        resultado.MontoProductoMasVendido = productoMasVendido.MontoTotalVendido;
                        resultado.CantidadProductoMasVendido = productoMasVendido.CantidadTotalVendida;
                    }
                }

                // Local con mayor venta
                var localMayorVenta = await datos
                    .GroupBy(x => x.IdVentaNavigation.IdLocal)
                    .Select(g => new
                    {
                        CodigoLocal = g.Key,
                        MontoTotalVendido = g.Sum(x => x.IdVentaNavigation.Total)
                    })
                    .OrderByDescending(x => x.MontoTotalVendido)
                    .FirstOrDefaultAsync();

                if (localMayorVenta != null)
                {
                    var local = await datos
                        .FirstOrDefaultAsync(l => l.IdVentaNavigation.IdLocal == localMayorVenta.CodigoLocal);

                    if (local != null)
                    {
                        resultado.LocalMayorVenta = local.IdVentaNavigation.IdLocalNavigation.Nombre;
                        resultado.MontoLocalMayorVenta = localMayorVenta.MontoTotalVendido;
                    }
                }

                // Marca de Producto con mayor margen de ganancia
                var productoMayorGanancia = await datos
                    .GroupBy(x => x.IdProductoNavigation.IdMarca)
                    .Select(g => new
                    {
                        CodigoMarca = g.Key,
                        MargenGanancia = g.Sum(x => x.PrecioUnitario - x.IdProductoNavigation.CostoUnitario)
                    })
                    .OrderByDescending(x => x.MargenGanancia)
                    .FirstOrDefaultAsync();

                if (productoMayorGanancia != null)
                {
                    var marca = await datos
                        .FirstOrDefaultAsync(x => x.IdProductoNavigation.IdMarca == productoMayorGanancia.CodigoMarca);

                    if (marca != null)
                    {
                        resultado.MarcaMayorGanancia = marca.IdProductoNavigation.IdMarcaNavigation.Nombre;
                        resultado.MontoMarcaMayorGanancia = productoMayorGanancia.MargenGanancia;
                    }
                }

                // Consulta de productos más vendidos
                var ventasPorLocal = datos
                    .GroupBy(v => v.IdVentaNavigation.IdLocal)
                    .Select(g => new
                    {
                        CodigoLocal = g.Key,
                        TotalVendido = g.Sum(v => v.TotalLinea)
                    })
                    .ToList();

                var productosMasVendidosPorLocal = ventasPorLocal
                    .Select(v => new
                    {
                        CodigoLocal = v.CodigoLocal,
                        ProductoMasVendido = datos
                            .Where(vd => vd.IdVentaNavigation.IdLocal == v.CodigoLocal)
                            .GroupBy(vd => vd.IdProducto)
                            .Select(g => new
                            {
                                CodigoProducto = g.Key,
                                TotalVendido = g.Sum(vd => vd.TotalLinea)
                            })
                            .OrderByDescending(x => x.TotalVendido)
                            .FirstOrDefault()
                    })
                    .Join(_context.Locales,
                        venta => venta.CodigoLocal,
                        local => local.IdLocal,
                        (venta, local) => new
                        {
                            CodigoLocal = venta.CodigoLocal,
                            NombreLocal = local.Nombre,
                            CodigoProducto = venta.ProductoMasVendido.CodigoProducto,
                            TotalVendido = venta.ProductoMasVendido.TotalVendido
                        })
                    .Join(_context.Productos,
                        venta => venta.CodigoProducto,
                        producto => producto.IdProducto,
                        (venta, producto) => new
                        {
                            venta.CodigoLocal,
                            venta.NombreLocal,
                            venta.CodigoProducto,
                            venta.TotalVendido,
                            NombreProducto = producto.Nombre
                        });

                resultado.ProductosMasVendidos = new List<ProductoMasVendidoViewModel>();

                foreach (var productoMasVendidoPorLocal in productosMasVendidosPorLocal.OrderByDescending(x => x.TotalVendido))
                {
                    resultado.ProductosMasVendidos.Add(new ProductoMasVendidoViewModel
                    {
                        CodigoLocal = productoMasVendidoPorLocal.CodigoLocal,
                        NombreLocal = productoMasVendidoPorLocal.NombreLocal,
                        CodigoProducto = productoMasVendidoPorLocal.CodigoProducto,
                        NombreProducto = productoMasVendidoPorLocal.NombreProducto,
                        TotalVendido = productoMasVendidoPorLocal.TotalVendido
                    });
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw;
            }
            
            return resultado;
        }
    }
}
