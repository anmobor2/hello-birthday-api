import pytest
from datetime import date
from app.services.date_service import DateService


class TestDateService:
    def test_calculate_days_until_birthday_today(self):
        # Probar cuando el cumpleaños es hoy
        birth_date = date(1990, 5, 15)
        reference_date = date(2023, 5, 15)

        is_today, days_until = DateService.calculate_days_until_birthday(birth_date, reference_date)

        assert is_today is True
        assert days_until == 0

    def test_calculate_days_until_birthday_future(self):
        # Probar cuando el cumpleaños es en el futuro
        birth_date = date(1990, 5, 20)
        reference_date = date(2023, 5, 15)

        is_today, days_until = DateService.calculate_days_until_birthday(birth_date, reference_date)

        assert is_today is False
        assert days_until == 5

    def test_calculate_days_until_birthday_past(self):
        # Probar cuando el cumpleaños ya pasó este año
        birth_date = date(1990, 5, 10)
        reference_date = date(2023, 5, 15)

        is_today, days_until = DateService.calculate_days_until_birthday(birth_date, reference_date)

        assert is_today is False
        assert days_until == 361  # 365 - 5 días

    def test_leap_year(self):
        # Probar años bisiestos
        assert DateService.is_leap_year(2020) is True
        assert DateService.is_leap_year(2000) is True
        assert DateService.is_leap_year(1900) is False
        assert DateService.is_leap_year(2023) is False

    def test_calculate_days_leap_year(self):
        # Probar cálculo correcto en años bisiestos
        birth_date = date(1990, 3, 1)

        # Caso 1: El año de referencia es bisiesto y el cumpleaños es después del 29 de febrero
        reference_date = date(2020, 2, 20)
        is_today, days_until = DateService.calculate_days_until_birthday(birth_date, reference_date)
        assert days_until == 10  # El año es bisiesto, así que es un día más que en años normales

        # Caso 2: El año de referencia no es bisiesto
        reference_date = date(2023, 2, 20)
        is_today, days_until = DateService.calculate_days_until_birthday(birth_date, reference_date)
        assert days_until == 9
