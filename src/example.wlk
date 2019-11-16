/** First Wollok example */
class Sobreviviente {
  var property carisma
  var property resistencia
  var estado 
  var property armas = []
  const poderPropio =0
  
  method armaRandom(){
  	return armas.anyOne()
  }
  
  method aumentarCarisma(cantidad){
  carisma += cantidad
  }
  method aumentarResistencia(cantidad){
  resistencia += cantidad
  }
  method disminuirResistencia(cantidad){
  resistencia -= cantidad
  }
  method puedeAtacar() {
  return resistencia >12
  }
  

  method infectado(){
  	estado = new Infectado()
  }
  method desmayarse(){
  estado= new Desmayado()
  }
  method saludable(){
  estado = new Saludable()
  }
  method poderOfensivo(){
   return armas.anyOne().poderOfensivo() + poderPropio * (1 + carisma/100)
  }
  /*--------------------------------2B-------------------------------------------------- */
  method agregarArmas(armasNuevas){
  	armas.addAll(armasNuevas)
  }
  /*--------------------------------2A-------------------------------------------------- */
  method comer(guarnicionCuradora){
    estado.comer(self)
  }
  /*--------------------------------1B-------------------------------------------------- */
  method atacarA(caminante){
  resistencia -=2
  estado.alAtacara(self)
  }
  }
  
  //estados
  class Estado {
  method alAtacarA(sobreviviente)
  method comer(sobreviviente)
  }
  
  class Saludable {
  // no tiene efectos
  }
  
  class Arrebatado{
  method alAtacar(sobreviviente){
  sobreviviente.aumentarCarisma(1)
  }
  method comer(sobreviviente){
  sobreviviente.aumentarCarisma(20)
  sobreviviente.aumentarResistencia(50)
  }
  }
  
  class Infectado{
  var ataquesRealizados =0
  
  method alAtacar(sobreviviente){
  sobreviviente.disminuirResistencia(3)
  if(ataquesRealizados==5){
  sobreviviente.desmayarse()
  }
  }
  
  method comer(sobreviviente){
  	sobreviviente.aumentarResistencia(40)
 	 if(ataquesRealizados >3){
  		ataquesRealizados=0
  	}else{
  	sobreviviente.saludable()
  	}
  	}
  }
  class Desmayado{
 
  method AlAtacar(){
  //no efecto
  }
  
  method comer(sobreviviente){
  sobreviviente.saludable()
  }
  }
  
  class Predadores inherits Sobreviviente{
  	
	var caminantes=[]
	
	override method poderOfensivo(){
	return super()/2 + caminantes.sum({caminante => caminante.poderCorrosivo()})
	}
	method intentarEsclavizar(caminante){
		if(caminante.estaDebil())
		caminantes.add(caminante)
	}
  	override method atacarA(caminante){
  		super(caminante)
  		self.intentarEsclavizar(caminante)
  		
  	}
  }
  //caminantes
  class Caminante{
  var sedDeSangre
  var somnoliento = false
  var dientes
  
  method estaDebil(){
  	return sedDeSangre <15 and somnoliento 
  }
  method poderCorrosivo (){
  return 2 * sedDeSangre + dientes
  }
  method serAtacadoPor(sobreviviente){
  	sobreviviente.atacarA(self)
  }
  
  }
  //Grupo
  class Grupo {
  var lugarActual
  var lugaresTomados =#{}
  var property sobrevivientes=#{}
  
  method sobrevivienteRandom(){
  	return sobrevivientes.anyOne()
  }
  /*--------------------------------------1C-------------------------------------------------- */
  method poderOfensivo(){
  	return self.poderOfensivoAtacantes()*self.lider().carisma()
  }
  method poderOfensivoAtacantes(){
  	return self.atacantes().sum({atacante => atacante.poderOfensivo()})
  }
  method lider(){
  	return sobrevivientes.max({sobreviviente => sobreviviente.carisma()})
  }
/*----------------------------------------1A-------------------------------------------------- */
  method atacantes(){
  return sobrevivientes.filter({sobreviviente => sobreviviente.puedeAtacar()})
  }
  /*------------------------------------3B-------------------------------------------------- */
  method masDebil(){
  return	sobrevivientes.min({sobreviviente=>sobreviviente.poderOfensivo()})
  }
    /*------------------------------------3C-------------------------------------------------- */
    method moverseA(lugar){
    	lugarActual=lugar
    	
    }
    method integrantesJodidos(){
    	 return sobrevivientes.filter({sobreviviente => sobreviviente.resistencia()<40})
    }
  method tomarLugar(lugar){
  	if(lugar.puedeTomarse(self)){
  		self.moverseA(lugar)
  		lugar.caminantes().forEach({caminante=>caminante.serAtacadoPor(self.atacantes().atRandom())})
  		lugaresTomados.add(lugar)
  		lugar.efecto()
  		}else{
  		self.integrantesJodidos().forEach({sobreviviente=>sobreviviente.infectado()}) and
  		sobrevivientes.remove(self.masDebil())
  	}
  	
  }
  }
  
  //Lugar
  class Lugar{
  	var property caminantes = #{}
  	
  	method efectoAlTomar(grupo)
  	/*--------------------------------3A-------------------------------------------------- */
  	method puedeTomarse(grupo){
  		return self.poderCorrosivo()<grupo.poderOfensivo() and self.puedeTomarseEspecifico(grupo)
  	}
  	method puedeTomarseEspecifico(grupo)
  	
  	method poderCorrosivo(){
  		return caminantes.sum({caminante => caminante.poderCorrosivo()})
  	}
  }
  
  class Prision inherits Lugar {
  	var pabellones
  	var armeria = []
  	override method puedeTomarseEspecifico(grupo)
  	{
  		return grupo.poderOfensivo()> pabellones *2
  	}
  	override method efectoAlTomar(grupo){
  		grupo.masDebil().armas().adAll(armeria)
  	}	
  }
  
  class Bosque inherits Lugar{
  	var niebla = false
  	override method puedeTomarseEspecifico(grupo)
  	{
  		return !(grupo.sobrevivientes().any({sobreviviente => sobreviviente.armas().esRuidosa()}))
  	}
  	override method efectoAlTomar(grupo){
  		if(niebla){
  			grupo.sobrevivienteRandom().remove(grupo.sobrevivienteRandom().armaRandom())
  		}
  	}
  }
  
  class Granja inherits Lugar{
  	var guarnicionCuradora
  	override method puedeTomarseEspecifico(grupo)
  	{
  		
  	}
  	override method efectoAlTomar(grupo){
  		grupo.sobrevivientes().forEach({sobreviviente=> sobreviviente.comer(guarnicionCuradora)})
  	}
  }
  
  class Arma{
  var calibre
  var potenciaDestructiva
  method poderOfensivo(){
     return 2 * calibre + potenciaDestructiva
  }
}
  class ArmaRuidosa inherits Arma{
    method esRuidosa(){
      return true
    }
  }
  
  class ArmaSilenciosa inherits Arma{
	method esRuidosa()
	{
		return false
	}
  }
  /*¿Qué pasaría si hay un sobreviviente que no quiere trabajar en grupo, y quisiera tomar un lugar solo? 
   * No seria posible
¿Debería hacer cambios en su modelo de objetos? ¿Cualés? 
* quizas hacer que ese sobreviviente sea una clase que herede de grupo y reescribir sus metodos acorde
¿Qué concepto lo ayudaría con esto y por qué?
  herencia y polimorfismo
   * 
   */
  