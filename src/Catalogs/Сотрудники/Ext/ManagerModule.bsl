﻿Функция ВалидацияПолейФио(Знач текст, этоФамилия = Ложь) Экспорт
    шаблонПоиска = "^(?:[А-ЯЁ][а-яА-ЯЁё]+)$";
    шаблонПоиска = ?(этоФамилия,
            Лев(шаблонПоиска, СтрДлина(шаблонПоиска) - 1) + "(?:\-[А-ЯЁ][а-яА-ЯЁё]+)?$", шаблонПоиска);
    Возврат СтрПодобнаПоРегулярномуВыражению(текст, шаблонПоиска);
КонецФункции
