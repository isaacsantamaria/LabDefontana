using LabDefontana.Data;
using LabDefontana.Models;
using LabDefontana.Repository.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace LabDefontana.Repository
{
    public class VentaRepository : IVentaRepository
    {
        private readonly ApplicationDbContext _context;

        public VentaRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public IQueryable<VentaDetalle> ObtenerVentasDetalles(int ultimosDias)
        {
            return _context.VentaDetalles
                .Include(x => x.IdProductoNavigation)
                .Include(x => x.IdVentaNavigation)
                .Include(x => x.IdVentaNavigation.IdLocalNavigation)
                .Include(x => x.IdProductoNavigation.IdMarcaNavigation)
                .Where(x => x.IdVentaNavigation.Fecha >= DateTime.Now.AddDays(ultimosDias * -1))
                .AsQueryable();
        }
    }
}
