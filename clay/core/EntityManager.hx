package clay.core;



import clay.ds.Int32RingBuffer;
import clay.ds.BitVector;
import clay.containers.EntityVector;

import clay.Entity;

class EntityManager {


	public var capacity (default, null):Int; // 16384, 65536
	public var used (default, null): Int;
	public var available(get, never):Int;
	
	public var componentManager:ComponentManager;

	//var oncreate:Entity->ComponentManager->Void;
	var oncreate:(e:Entity, c:ComponentManager)->Void;
	var ondestroy:(e:Entity, c:ComponentManager)->Void;
	var onchanged:Entity->Void;

	var _id_pool : Int32RingBuffer;
	
	var _alive_mask : BitVector;
	var _active_mask : BitVector;
	var _entities : EntityVector;


	public function new(_capacity:Int) {

		if((_capacity & (_capacity - 1)) != 0) {
			throw('EntityManager capacity: $_capacity must be power of two');
		}

		capacity = _capacity;
		used = 0;

		_id_pool = new Int32RingBuffer(capacity);

		_entities = new EntityVector(capacity);

		_alive_mask = new BitVector(capacity);
		_active_mask = new BitVector(capacity);

	}

	@:access(clay.containers.EntityVector)
	public function New_Entity(_active:Bool = true) : Entity {

		var id:Int = pop_entity_id();
		var e:Entity = new Entity(id); 

		_alive_mask.enable(id);

		if(_active) {
			_active_mask.enable(id);
		}

		_entities._add(id);

		if(oncreate != null) {
			oncreate(e, componentManager);
		}

		return e;

	}

	@:access(clay.containers.EntityVector)
	public function destroy(e:Entity) {

		var id:Int = e.id;

		if(!has(e)) {
			throw('entity $id destroying repeatedly ');
		}

		_alive_mask.disable(id);
		_active_mask.disable(id);

		_entities._remove(id);
		push_entity_id(id);

		if(ondestroy != null) { // is there right place?
			ondestroy(e, componentManager);
		}

	}

	public inline function has(e:Entity):Bool {

		return _alive_mask.get(e.id);

	}

	// check if it has id first
	public inline function get(id:Int):Entity {

		if(!_alive_mask.get(id)) {
			//throw('get / entity ${id} is not found');
		}

		return new Entity(id);

	}

	public inline function is_active(e:Entity):Bool {

		if(!has(e)) {
			//throw('is_active / entity ${e.id} is not found');
			trace('is_active / entity ${e.id} is not found');
		}

		return _active_mask.get(e.id);
		
	}

	public inline function activate(e:Entity) {

		if(!has(e)) {
			//throw('activate / entity ${e.id} is not found');
			trace('activate / entity ${e.id} is not found');
		}

		_active_mask.enable(e.id);

		if(onchanged != null) {
			onchanged(e);
		}

	}

	public inline function deactivate(e:Entity) {

		if(!has(e)) {
			//throw('deactivate / entity ${e.id} is not found');
			trace('deactivate / entity ${e.id} is not found');
		}

		_active_mask.disable(e.id);

		if(onchanged != null) {
			onchanged(e);
		}

	}

		/** destroy EntityManager */
	@:noCompletion public function destroy_manager() {

		clear();

		_entities = null;
		_alive_mask = null;
		_active_mask = null;
		_id_pool = null;
		
	}

		/** remove and destroy all _entities */
	public function clear() {

		for (e in _entities) {
			destroy(e);
		}

		_alive_mask.clear();
		_active_mask.clear();
		_id_pool.clear();

	}


	function get_available():Int {

		return capacity - used;

	}

	function pop_entity_id():Int {

		if(used >= capacity) {
			throw('Out of entities, max allowed ${capacity}');
		}

		++used;
		return _id_pool.pop();

	}

	function push_entity_id(_id:Int) {

		--used;
		_id_pool.push(_id);

	}

	inline function toString() {

		var _list = []; 

		for (e in _entities) {
			_list.push(e);
		}

		return 'entities: [${_list.join(", ")}]';

	}

	@:noCompletion public inline function iterator():EntityVectorIterator {

		return _entities.iterator();

	}


}