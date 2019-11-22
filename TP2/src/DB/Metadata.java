package DB;

public class Metadata {
	
	private int clientes;
	private int facturas;
	
	public Metadata() {
		clientes = 0;
		facturas = 0;
	}
	
	public void addClientes() {
		clientes++;
	}
	
	public void addFacturas() {
		facturas++;
	}
	
	public int getClientes() {
		return clientes;
	}
	
	public int getFacturas() {
		return facturas;
	}
	
}
