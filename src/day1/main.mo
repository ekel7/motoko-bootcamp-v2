import Float "mo:base/Float";

actor Counter {

    // Paso 1 -  Define una variable mutable llamada counter.
    var counter : Float = 0.0;

    // Paso 2 - Implementa el add.
    public shared func add(x : Float) : async Float {
        counter += x;
        return counter;
    };

    // Paso 3 - Implementa el sub.
    public shared func sub(x : Float) : async Float {
        counter -= x;
        return counter;
    };

    // Paso 4 - Implementa el mul.
    public shared func mul(x : Float) : async Float {
        counter *= x;
        return counter;
    };

    // Paso 5 - Implementa el div.
    public shared func div(x : Float) : async ?Float {
        if (x == 0) {
            // 'null' da error al dividir por 0.
            return null;
        } else {
            counter /= x;
            return ?counter;
        };
    };

    // Paso 6 - Implementa el reset.
    public shared func reset() : async () {
        counter := 0;
    };

    // Paso 7 - Implementa el query.
    public shared query func see() : async Float {
        return counter;
    };

    // Paso 8 - Implementa el power.
    public shared func power(x : Float) : async Float {
        counter := Float.pow(counter, x);
        return counter;
    };

    // Paso 9 - Implementa el sqrt.
    public shared func sqrt() : async Float {
        counter := counter ** 0.5;
        return counter;
    };

    // Paso 10 - Implementa el floor.
    public shared func floor() : async Int {
        return Float.toInt(counter);
    };

};
