from datetime import date, datetime
from typing import Tuple, Optional


class DateService:
    @staticmethod
    def calculate_days_until_birthday(birth_date: date, reference_date: Optional[date] = None) -> Tuple[bool, int]:
        """
        Calcula los días restantes hasta el próximo cumpleaños.

        Args:
            birth_date: Fecha de nacimiento
            reference_date: Fecha de referencia (por defecto es la fecha actual)

        Returns:
            Tupla con (es_hoy, días_restantes)
            - es_hoy: True si el cumpleaños es hoy, False en caso contrario
            - días_restantes: Número de días hasta el próximo cumpleaños
        """
        if reference_date is None:
            reference_date = date.today()

        # Crear fecha del cumpleaños en el año actual
        current_year = reference_date.year
        birthday_this_year = date(current_year, birth_date.month, birth_date.day)

        # Si el cumpleaños ya pasó este año, calcular para el próximo año
        if birthday_this_year < reference_date:
            next_birthday = date(current_year + 1, birth_date.month, birth_date.day)
        else:
            next_birthday = birthday_this_year

        # Calcular la diferencia en días
        days_until = (next_birthday - reference_date).days

        # Verificar si el cumpleaños es hoy
        is_today = days_until == 0

        return (is_today, days_until)

    @staticmethod
    def is_leap_year(year: int) -> bool:
        """
        Determina si un año es bisiesto.

        Args:
            year: El año a verificar

        Returns:
            True si el año es bisiesto, False en caso contrario
        """
        return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)
