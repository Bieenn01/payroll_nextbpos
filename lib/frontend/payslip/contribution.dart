sssContribution(double salary) {
  if (salary < 4250) {
    return 0;
  } else if (salary <= 4250) {
    return 380.00;
  } else if (salary >= 4250 && salary <= 4749.99) {
    return 427.50;
  } else if (salary >= 4750 && salary <= 5249.99) {
    return 475.00;
  } else if (salary >= 5250 && salary <= 5749.99) {
    return 522.50;
  } else if (salary >= 5750 && salary <= 6249.99) {
    return 570.00;
  } else if (salary >= 6250 && salary <= 6749.99) {
    return 617.50;
  } else if (salary >= 6750 && salary <= 7249.99) {
    return 665.00;
  } else if (salary >= 7250 && salary <= 7749.99) {
    return 712.50;
  } else if (salary >= 7750 && salary <= 8249.99) {
    return 760.00;
  } else if (salary >= 8250 && salary <= 8749.99) {
    return 807.50;
  } else if (salary >= 8750 && salary <= 9249.99) {
    return 855.00;
  } else if (salary >= 9250 && salary <= 9749.99) {
    return 902.50;
  } else if (salary >= 9750 && salary <= 10249.99) {
    return 950.00;
  } else if (salary >= 10250 && salary <= 10749.99) {
    return 997.50;
  } else if (salary >= 10750 && salary <= 11249.99) {
    return 1045.00;
  } else if (salary >= 11250 && salary <= 11749.99) {
    return 1092.50;
  } else if (salary >= 11750 && salary <= 12249.99) {
    return 1140.00;
  } else if (salary >= 12250 && salary <= 12749.99) {
    return 1187.50;
  } else if (salary >= 12750 && salary <= 13249.99) {
    return 1235.00;
  } else if (salary >= 13250 && salary <= 13749.99) {
    return 1282.50;
  } else if (salary >= 13750 && salary <= 14249.99) {
    return 1330.00;
  } else if (salary >= 14250 && salary <= 14749.99) {
    return 1377.50;
  } else if (salary >= 14750 && salary <= 15249.99) {
    return 14250.00;
  } else if (salary >= 15250 && salary <= 15749.99) {
    return 1472.50;
  } else if (salary >= 15750 && salary <= 16249.99) {
    return 1520.00;
  } else if (salary >= 16250 && salary <= 16749.99) {
    return 1567.50;
  } else if (salary >= 16750 && salary <= 17249.99) {
    return 1615.00;
  } else if (salary >= 17250 && salary <= 17749.99) {
    return 1662.50;
  } else if (salary >= 17750 && salary <= 18249.99) {
    return 1710.00;
  } else if (salary >= 18250 && salary <= 18749.99) {
    return 1757.50;
  } else if (salary >= 18750 && salary <= 19249.99) {
    return 1805.00;
  } else if (salary >= 19250 && salary <= 19749.99) {
    return 1852.50;
  } else if (salary >= 19750 && salary <= 20249.99) {
    return 1900.00;
  } else if (salary >= 20250 && salary <= 20749.99) {
    return 1900.00;
  } else if (salary >= 20750 && salary <= 21249.99) {
    return 1900.00;
  } else if (salary >= 21250 && salary <= 21749.99) {
    return 1900.00;
  } else if (salary >= 21750 && salary <= 22249.99) {
    return 1900.00;
  } else if (salary >= 22250 && salary <= 22749.99) {
    return 1900.00;
  } else if (salary >= 22750 && salary <= 23249.99) {
    return 1900.00;
  } else if (salary >= 23250 && salary <= 23749.99) {
    return 1900.00;
  } else if (salary >= 23750 && salary <= 24249.99) {
    return 1900.00;
  } else if (salary >= 24250 && salary <= 24749.99) {
    return 1900.00;
  } else if (salary >= 24750 && salary <= 25249.99) {
    return 1900.00;
  } else if (salary >= 25250 && salary <= 25749.99) {
    return 1900.00;
  } else if (salary >= 25750 && salary <= 26249.99) {
    return 1900.00;
  } else if (salary >= 26250 && salary <= 26749.99) {
    return 1900.00;
  } else if (salary >= 26750 && salary <= 27249.99) {
    return 1900.00;
  } else if (salary >= 27250 && salary <= 27749.99) {
    return 1900.00;
  } else if (salary >= 27750 && salary <= 28249.99) {
    return 1900.00;
  } else if (salary >= 28250 && salary <= 28749.99) {
    return 1900.00;
  } else if (salary >= 28750 && salary <= 29249.99) {
    return 1900.00;
  } else if (salary >= 29250 && salary <= 29749.99) {
    return 1900.00;
  } else if (salary > 29750) {
    return 1900.00;
  } else {
    return 0;
  }
}

pagibigContribution() {
  return 200.00;
}

String phicContribution(double salary) {
  double contribution = salary * 0.05;
  return contribution.toStringAsFixed(2);
}

calculateWithholdingTax(double salary) {
  double tax = 0.0;
  if (salary <= 25000.0) {
    tax = salary * 0.20;
  } else if (salary <= 58333.33) {
    tax = 5000.0 + (salary - 25000.0) * 0.25;
  } else if (salary <= 125000.0) {
    tax = 10416.67 + (salary - 58333.33) * 0.30;
  } else if (salary <= 291666.67) {
    tax = 27083.33 + (salary - 125000.0) * 0.32;
  } else if (salary <= 666666.67) {
    tax = 79166.67 + (salary - 291666.67) * 0.35;
  } else {
    tax = 241666.67 + (salary - 666666.67) * 0.40;
  }
  return tax.toStringAsFixed(2);
}
