﻿#Область ПрограммныйИнтерфейс

// Параметры:
//  ЧислоСтрокой - Строка - Строка приводимая к числу
//  ВозвращатьНеопределено - Булево - Если Истина и строка содержит некорректное значение, то возвращать Неопределено
// Возвращаемое значение:
//  Число
Функция ПривестиСтрокуКЧислу(Знач числоСтрокой, Знач возвращатьНеопределено = Ложь) Экспорт
    описаниеТипаЧисла = Новый ОписаниеТипов("Число");
    результат = описаниеТипаЧисла.ПривестиЗначение(числоСтрокой);

    Если возвращатьНеопределено И (результат = 0) Тогда

        стр = Строка(числоСтрокой);
        Если стр <> "" Тогда
            Возврат Неопределено;
        КонецЕсли;

        стр = СтрЗаменить(СокрЛП(стр), "0", "");
        Если (стр <> "") И (стр <> ".") И (стр <> ",") Тогда
            Возврат Неопределено;
        КонецЕсли;
    КонецЕсли;

    Возврат результат;
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс
