package clay.core;

// from Mint by Sven Bergström https://github.com/snowkit/mint
// Contibuted by Michael Bickel http://github.com/dazKind

import haxe.macro.Expr;

class Signal<T> {

    public var listeners:Array<T>;

    public function new() {

        listeners = [];

    } //new

    public function add( _handler:T ):Void {

        if( listeners.indexOf(_handler) != -1 ) {
            throw "clay / signal / add / attempted to add the same listener twice";
            return;
        }

        listeners.push(_handler);

    } //add

    public function remove( _handler:T ):Void {

        var _index = listeners.indexOf(_handler);
        if(_index != -1) {
            listeners[_index] = null;
        }

    } //remove

    public inline function has( _handler:T ):Bool {

        return listeners.indexOf(_handler) != -1;

    } //has

    public inline function clear() {
        listeners = null;
        listeners = [];
    }

    macro public function emit( ethis : Expr, args:Array<Expr> ) {
        return macro {
            var _idx = 0;
            var _count = $ethis.listeners.length;
            while(_idx < _count) {
                if($ethis != null) {
                    var fn = $ethis.listeners[_idx];
                    if(fn != null) {
                        fn($a{args});
                    }
                }
                _idx++;
            }

            if($ethis != null) {
                while(_count > 0) {
                    var fn = $ethis.listeners[_count-1];
                    if(fn == null) $ethis.listeners.splice(_count-1, 1);
                    _count--;
                }
            }
        }
    } //emit

} //Signal
