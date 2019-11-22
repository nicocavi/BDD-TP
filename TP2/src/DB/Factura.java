package DB;

public class Factura {

	private int numero;
	private int id;
	private float importe;
	
	public Factura( int id, int numero, float importe) {
		this.id = id;
		this.numero = numero;
		this.importe = importe;
	}

	public int getNumero() {
		return numero;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public float getImporte() {
		return importe;
	}

	public void setImporte(float importe) {
		this.importe = importe;
	}
	
	public String getString() {
		return this.id+" | "+ this.numero+" | "+this.importe+" |";
	}
	
	
	
}
