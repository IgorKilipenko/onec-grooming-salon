﻿#Область ОбработчикиСобытий

Процедура КлиентПодтвердилРегистрациюПроверкаУсловия(ТочкаМаршрутаБизнесПроцесса, Результат)
    Результат = ЭтотОбъект.РегистрацияПодтверждена;
КонецПроцедуры

Процедура ПолучитьПодтверждениеРегистрацииПриСозданииЗадач(ТочкаМаршрутаБизнесПроцесса, ФормируемыеЗадачи, Отказ)
    Для Каждого формируемаяЗадача Из ФормируемыеЗадачи Цикл
        наименованиеЗадачи = СтрШаблон("Получить согласие клиента ""%1"" на регистрацию",
                ЭтотОбъект.ДокументРегистрацииПользователя.Имя);
        формируемаяЗадача.Наименование = наименованиеЗадачи;
        формируемаяЗадача.ДокументЗадачи = ЭтотОбъект.ДокументРегистрацииПользователя;
        формируемаяЗадача.ОписаниеЗадачи = СтрШаблон(
            "Из мобильного приложения поступила заявка на регистрацию пользователя.
            |
            |Необходимо созвониться с клиентом ""%1"" по телефону: %2 и получить согласие на регистрацию.
            |В случае получения согласия:
            |   1. Присвоить идентификатор пользователя;
            |   2. Указать в документе регистрации присвоенный идентификатор пользователя;
            |   3. Дозаполнить карточку клиента.",

                ЭтотОбъект.ДокументРегистрацииПользователя.Имя,
                ЭтотОбъект.ДокументРегистрацииПользователя.КонтактныйТелефон);

        формируемаяЗадача.ТипЗадачи = Перечисления.ТипыЗадачИсполнителя.РегистрацияПользователя;
    КонецЦикла;
КонецПроцедуры

Процедура ПолучитьПодтверждениеРегистрацииПриВыполнении(ТочкаМаршрутаБизнесПроцесса, Задача, Отказ)
    документЗадачи = Задача.ДокументЗадачи;

    ДиагностикаКлиентСервер.Утверждение(ЗначениеЗаполнено(документЗадачи),
        "Документ задачи должен быть заполнен.");

    ДиагностикаКлиентСервер.Утверждение(документЗадачи = ЭтотОбъект.ДокументРегистрацииПользователя,
            "Документ задачи не должен отличаться от документа задачи бизнес-процесса.");

    Если Задача.ПолученоСогласиеНаРегистрацию И НЕ ЗначениеЗаполнено(документЗадачи.Идентификатор) Тогда
        Сообщение = Новый СообщениеПользователю;
        Сообщение.Текст = "Поле ""Идентификатор"" документа регистрации пользователя должен быть заполнен уникальным значением.";
        Сообщение.Сообщить();
        Отказ = Истина;

        Возврат;
    КонецЕсли;

    ЭтотОбъект.РегистрацияПодтверждена = Задача.ПолученоСогласиеНаРегистрацию;
КонецПроцедуры

Процедура ПометкаНаУдалениеДокументаРегистрацииОбработка(ТочкаМаршрутаБизнесПроцесса)
    ЭтотОбъект.ДокументРегистрацииПользователя.ПолучитьОбъект().УстановитьПометкуУдаления(Истина);
КонецПроцедуры

Процедура СозданиеНовогоПользователяОбработка(ТочкаМаршрутаБизнесПроцесса)
    Справочники.Пользователи.СоздатьПользователя(
        ЭтотОбъект.ДокументРегистрацииПользователя.Имя, ЭтотОбъект.ДокументРегистрацииПользователя.Идентификатор,
        Новый Структура("ЭтоКлиент", Истина));
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий
