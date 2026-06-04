rec {
  pow = base: exp: if exp == 0 then 1 else base * pow base (exp - 1);
  greeting = name: "Hello, ${name}!";
}
