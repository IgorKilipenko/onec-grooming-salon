﻿#Область ОбработчикиСобытий

Процедура ОбработкаПроверкиЗаполнения(отказ, проверяемыеРеквизиты)
    реквизитыОбъекта = ЭтотОбъект.Метаданные().Реквизиты;
    Если проверитьРеквизитИзСоставаФИО(реквизитыОбъекта.Фамилия.Имя, ЭтотОбъект.Фамилия) = Ложь Тогда
        отказ = Истина;
        исключитьНепроверяемыйРеквизит(реквизитыОбъекта.Фамилия.Имя, проверяемыеРеквизиты);
        Возврат;
    КонецЕсли;

    Если НЕ проверитьРеквизитИзСоставаФИО(реквизитыОбъекта.Имя.Имя, ЭтотОбъект.Имя) Тогда
        отказ = Истина;
        исключитьНепроверяемыйРеквизит(реквизитыОбъекта.Имя.Имя, проверяемыеРеквизиты);
        Возврат;
    КонецЕсли;

    Если ЗначениеЗаполнено(ЭтотОбъект.Отчество)
        И проверитьРеквизитИзСоставаФИО(реквизитыОбъекта.Отчество.Имя, ЭтотОбъект.Отчество) = Ложь Тогда
        отказ = Истина;
        исключитьНепроверяемыйРеквизит(реквизитыОбъекта.Фамилия.Имя, проверяемыеРеквизиты);
        Возврат;
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий

#Область СлужебныеПроцедурыИФункции

Функция проверитьРеквизитИзСоставаФИО(Знач имя, Знач значение)
    Если НЕ Справочники.Сотрудники.ВалидацияПолейФио(значение, имя = "Фамилия") Тогда
        сообщение = Новый СообщениеПользователю();
        сообщение.Текст = СтрШаблон("Неверный формат ввода поля ""%1"".", имя);
        сообщение.Поле = имя;
        сообщение.УстановитьДанные(ЭтотОбъект);
        сообщение.Сообщить();

        Возврат Ложь;
    КонецЕсли;

    Возврат Истина;
КонецФункции

Процедура исключитьНепроверяемыйРеквизит(Знач имяРеквизита, Знач проверяемыеРеквизиты) Экспорт
    индексЭлемента = проверяемыеРеквизиты.Найти(имяРеквизита);
    Если индексЭлемента >= 0 Тогда
        проверяемыеРеквизиты.Удалить(индексЭлемента);
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // СлужебныеПроцедурыИФункции
