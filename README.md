# Clay - GML
Entity-Component-System in haxe. For SFGML Export for using in Game maker studio 1/2;

Do you want to write code in a good programming language, but at the same time use the full power of the ease of gml-api? Yes, and faster code, fantastic, this is possible! Use sfgml!

https://yal.cc/r/18/sfgml/ - this is fantastic!

Why fork? I had to redo a couple of things, because gml does not support references to non-static class methods. There are a couple of restrictions about which you can read in the corresponding sfgml help.

##### Usage
```haxe

import clay.Entity;
import clay.Components;
import clay.Family;
import clay.Processor;
import clay.core.EntityManager;
import clay.core.FamilyManager;
import clay.core.ProcessorManager;
import clay.core.ComponentManager;


class ComponentA {

	public var string : String;

	public function new( _string:String ) : Void {
		string = _string;
	}

}

class ComponentB {

	public var int : Int;

	public function new( _int:Int ) : Void {
		int = _int;
	}

}

class ProcessorA extends Processor {


	var ab_family:Family;
	var a_comps:Components<ComponentA>;
	var b_comps:Components<ComponentB>;


	public function new() {

		super();

	}

	override function onadded() {

		a_comps = components.get_table(ComponentA);
		b_comps = components.get_table(ComponentB);

		ab_family = families.get('ab_family');

		ab_family.onadded.add(_entity_added);
		ab_family.onremoved.add(_entity_removed);

	}

	override function onremoved() {

		ab_family.onadded.remove(_entity_added);
		ab_family.onremoved.remove(_entity_removed);
		
	}

	override function update(dt:Float) {

		for (e in ab_family) {
			var a = a_comps.get(e);
			var b = b_comps.get(e);
			trace(a.string);
			trace(b.int);
		}

	}

	function _entity_added(e:Entity) {
		
		trace('entity: $e added');

	}
	
	function _entity_removed(e:Entity) {

		trace('entity: $e removed');

	}

}

class Main {

	static function main():Void {

		var entities = new EntityManager(16384);
		var components = new ComponentManager(entities);
		var families = new FamilyManager(components);
		var processors = new ProcessorManager(entities, components, families);

		families.create('ab_family', [ComponentA, ComponentB]);
		processors.add(new ProcessorA());

		var e1 = entities.create();
		var e2 = entities.create();
		components.set_many(e1, [new ComponentA('some_string'), new ComponentB(112358)]);
		components.set_many(e2, [new ComponentA('other_string'), new ComponentB(1618)]);

		processors.update(1/60);

	}

}


```
