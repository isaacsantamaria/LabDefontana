using LabDefontana.Models;

namespace LabDefontana.Repository.Interfaces
{
    public interface IVentaRepository
    {
        IQueryable<VentaDetalle> ObtenerVentasDetalles(int ultimosDias);
    }
}
