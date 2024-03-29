﻿#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Заполнить(_)
    Объект.Начисления.Очистить();
    началоПериода = НачалоМесяца(Объект.ПериодНачисления);
    конецПериода = КонецМесяца(Объект.ПериодНачисления);

    заполнитьТаблицуНачисленийНаСервере(началоПериода, конецПериода);

    ЭтотОбъект.Модифицированность = Истина;
КонецПроцедуры

#КонецОбласти // ОбработчикиКомандФормы

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура заполнитьТаблицуНачисленийНаСервере(Знач началоПериода, Знач конецПериода)
    параметрыЗапроса = Новый Структура("НачалоПериода, КонецПериода",
            началоПериода, конецПериода);
    кадроваяИсторияСотрудников = РегистрыСведений.КадроваяИсторияСотрудников.ПолучитьКадровыеДанныеИнтервал(
            Неопределено, параметрыЗапроса, Истина);

    Если кадроваяИсторияСотрудников = Неопределено Тогда
        сообщение = Новый СообщениеПользователю;
        сообщение.Текст = "Кадровая история за период начисления отсутствует.";
        сообщение.Сообщить();

        Возврат; // Выход
    КонецЕсли;

    предСтрока = Неопределено;
    Для Каждого данныеСотрудника Из кадроваяИсторияСотрудников Цикл
        строкаНачисления = Объект.Начисления.Добавить();

        строкаНачисления.ВидРасчета = ПланыВидовРасчета.Начисления.Оклад;
        строкаНачисления.Сотрудник = данныеСотрудника.Сотрудник;
        строкаНачисления.ГрафикРаботы = данныеСотрудника.ГрафикРаботы;
        строкаНачисления.ДатаНачала = Макс(началоПериода, данныеСотрудника.Период);
        строкаНачисления.ДатаОкончания = ?(данныеСотрудника.Работает, конецПериода, данныеСотрудника.Период);
        строкаНачисления.ПоказательРасчета = данныеСотрудника.Оклад;

        // Если кадровая история по сотруднику менялась в течении текущего периода
        Если предСтрока <> Неопределено И предСтрока.Сотрудник = данныеСотрудника.Сотрудник Тогда
            Если данныеСотрудника.Работает Тогда
                предСтрока.ДатаОкончания = получитьПредыдущийДень(строкаНачисления.ДатаНачала);

            // Обработка особого случая увольнения сотрудника, когда кадровая история менялась
            // в текущем периоде (том-же периоде когда и увольнение) например: если сотрудник устроился
            // и уволился в течении одного месяца
            Иначе
                предСтрока.ДатаОкончания = строкаНачисления.ДатаНачала;
                Объект.Начисления.Удалить(Объект.Начисления.Количество() - 1);

                Продолжить;
            КонецЕсли;
        КонецЕсли;

        предСтрока = строкаНачисления;
    КонецЦикла;
КонецПроцедуры

// Устарела. Нужно доработать с учетом графика работы
Функция получитьПредыдущийДень(Знач дата)
    Возврат дата - 24 * 60 * 60;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
