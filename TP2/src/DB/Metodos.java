package DB;

import java.util.ArrayList;
import java.util.Collections;

import com.db4o.Db4oEmbedded;
import com.db4o.ObjectContainer;
import com.db4o.ObjectSet;

public class Metodos {
	
	
	static void Open(ObjectContainer db) {
		try {			
			db = Db4oEmbedded.openFile("db4o");
		}catch(Exception e) {
			System.out.println("Error al iniciar la conexion");
		}
	}
	
	static void Close(ObjectContainer db) {
		try {			
			db.close();
		}catch(Exception e) {
			System.out.println("Error al cerrar la conexion");
		}
	}
	
	private static Metadata addMetadata(ObjectContainer db) {
		Metadata m = new Metadata();
		db.store(m);
		return m;
	}
	
	private static Metadata obtenerMetadata(ObjectContainer db) {
		Metadata meta = new Metadata();
		try {
			ObjectSet<Object> c = db.queryByExample(Metadata.class);	
			 meta = (Metadata) c.get(0);
		}catch(Exception e){
			meta = addMetadata(db);
		}
		
		return meta;
	}
	
	private static void actualizarMetadataCliente(ObjectContainer db) {
		Metadata aux = obtenerMetadata(db);
		db.delete(aux);
		aux.addClientes();
		db.store(aux);
	}
	
	private static void actualizarMetadataFactura(ObjectContainer db) {
		Metadata aux = obtenerMetadata(db);
		db.delete(aux);
		aux.addFacturas();
		db.store(aux);
	}
	
	public static void addCliente(ObjectContainer db, String des) {
		Metadata auxM = obtenerMetadata(db);
		try {
			Cliente cliente = new Cliente(auxM.getClientes(), des);
			db.store(cliente);
			actualizarMetadataCliente(db); 
			System.out.println("Se ha almacenado correctamente el cliente");
		}catch(Exception e){
			System.out.println("Se ha producido un error en la insercion del cliente");
		}
	}
	
	public static ArrayList<Cliente> selectCliente(ObjectContainer db) {
		ArrayList<Cliente> lc = new ArrayList<Cliente>();
		
		ObjectSet<Object> c = db.queryByExample(Cliente.class);	
		for(Object lCliente : c) lc.add((Cliente) lCliente);
		
		return lc;
	}
	
	
	public static Cliente selectCliente(ObjectContainer db, int id) {
	
		if(hayCliente(db,id)) {
			int x=0;
			ArrayList<Cliente> lc = selectCliente(db);
			for(int i = 0;i<lc.size();i++)
				if(lc.get(i).getId()==id)
					x = i;
			return lc.get(x);
		}else
			System.out.println("No existe el cliente");
			return null;
		 
	}
	
	private static boolean hayCliente(ObjectContainer db, int id) {
		boolean b = false;
		ArrayList<Cliente> listCliete = selectCliente(db);
		for(int i = 0;i<listCliete.size();i++)
			if(listCliete.get(i).getId()==id && !b)	b=true;
		return b;
	}
	
	public static void updateCliente(ObjectContainer db, int id, String descripcion) {
		Cliente c = selectCliente(db,id);
		if(c != null) {
			c.setDescripcion(descripcion);
			Cliente aux = c;
			db.store(aux);
			db.commit();
		}else {
			System.out.println("No existe el cliente");
		}
		
	}
	
	
	public static void deleteCliente(ObjectContainer db,int id) {
		Cliente c = selectCliente(db, id);
		if(c != null){
			db.delete(c);
			db.commit();
			System.out.println("El cliente fue eliminado");
		}else {
			System.out.println("El cliente no existe");
		}
	}
	
	public static void addFactura(ObjectContainer db, int id, float importe) {
			Metadata auxM = obtenerMetadata(db);
			Cliente c = selectCliente(db, id);
			if(c != null) {
				Factura factura = new Factura(id, auxM.getFacturas(), importe);
				actualizarMetadataFactura(db);
				try {
					db.store(factura);
					
					System.out.println("Se ha almacenado correctamente la factura");
				}catch(Exception e){
					System.out.println("Se ha producido un error en la insercion de la factura");
					System.out.println(e);
				}
			}else {				
				System.out.println("El cliente no existe");
			}
		
	}
	
	
	public static Factura selectFactura(ObjectContainer db, int num) {
	
		if(hayFactura(db, num)) {
			int x=0;
			ArrayList<Factura> lf = selectFactura(db);
			for(int i = 0;i<lf.size();i++)
				if(lf.get(i).getNumero()==num)
					x = i;
			return lf.get(x);
		}else
			System.out.println("No existe la factura");
			return null;
		 
	}
	

	private static boolean hayFactura(ObjectContainer db, int num) {
		boolean b = false;
		ArrayList<Factura> listFactura = selectFactura(db);
		for(int i = 0;i<listFactura.size();i++)
			if(listFactura.get(i).getNumero()==num && !b)	b=true;
		return b;
	}
	
	
	public static ArrayList<Factura> selectFactura(ObjectContainer db) {
		ArrayList<Factura> lf = new ArrayList<Factura>();
		
		ObjectSet<Object> f = db.queryByExample(Factura.class);	
		for(Object lFactura : f) lf.add((Factura) lFactura);
		
		return lf;
	}
	
	public static void updateFactura(ObjectContainer db, int id, int nro, float importe) {
		Factura f = selectFactura(db,nro);
		if(f != null) {
			if(selectCliente(db,id) != null) {
				f.setImporte(importe);
				f.setId(id);
				Factura aux = f;
				db.store(aux);
				db.commit();
				System.out.println("Factura actualizada");
			}else {
				System.out.println("No existe el cliente");
			}	
			
		}else {
			System.out.println("No existe la factura que desea actualizar");
		}
	}
	public static void deleteFactura(ObjectContainer db, int nro) {
		Factura aux  = selectFactura(db, nro);
		if(aux != null){
			db.delete(aux);
			System.out.println("La factura fue eliminado");
		}else {
			System.out.println("La factura no existe");
		}
	}
	
}
