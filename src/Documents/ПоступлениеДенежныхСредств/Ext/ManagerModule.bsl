﻿#Область ПрограммныйИнтерфейс

// Возвращает ссылку на документ РеализацияТоваровИУслуг созданный на основании документОснованиеСсылка.\
// Документ РеализацияТоваровИУслуг должен иметь статус: Проведен.
// Параметры:
//	документОснованиеСсылка - ДокументСсылка.ЗаписьКлиента
//	типДокументаРеализации - Тип, Неопределено
// Возвращаемое значение:
//	- ДокументСсылка.РеализацияТоваровИУслуг, Неопределено
Функция ПолучитьДокументРеализацииНаОсновании(Знач документОснованиеСсылка, типДокументаРеализации = Неопределено) Экспорт
    Если НЕ ЗначениеЗаполнено(документОснованиеСсылка) Тогда
        Возврат Неопределено;
    КонецЕсли;

    типДокументаРеализацииПоУмолчанию = Тип("ДокументСсылка.РеализацияТоваровИУслуг");
    типДокументаРеализации = ?(типДокументаРеализации = Неопределено, типДокументаРеализации,
            типДокументаРеализацииПоУмолчанию);

    этоДопустимыйТипДокумента = типДокументаРеализации = типДокументаРеализацииПоУмолчанию;
    Если НЕ этоДопустимыйТипДокумента Тогда
        Возврат Неопределено;
    КонецЕсли;

    запросДокументаРеализации = Новый Запрос;
    запросДокументаРеализации.УстановитьПараметр("Ссылка", документОснованиеСсылка);

    текстЗапроса =
        "ВЫБРАТЬ ПЕРВЫЕ 1
        |	ДокументРеализация.Ссылка КАК Ссылка
        |ИЗ
        |	Документ.РеализацияТоваровИУслуг КАК ДокументРеализация
        |ГДЕ
        |	ДокументРеализация.ДокументОснование = &Ссылка
        |		И ДокументРеализация.Проведен
        |";

    текстЗапроса = ?(типДокументаРеализации = типДокументаРеализацииПоУмолчанию, текстЗапроса,
            СтрЗаменить(текстЗапроса,
                Метаданные.НайтиПоТипу(типДокументаРеализацииПоУмолчанию).Имя,
                Метаданные.НайтиПоТипу(типДокументаРеализации).Имя));

    запросДокументаРеализации.Текст = текстЗапроса;

    результатЗапроса = запросДокументаРеализации.Выполнить();
    Если результатЗапроса.Пустой() Тогда
        Возврат Неопределено;
    КонецЕсли;

    выборка = результатЗапроса.Выбрать();
    выборка.Следующий();

    Возврат выборка.Ссылка;

КонецФункции

// Возвращаемое значение:
//	- Структура из КлючИЗначение
//      * Ключ - Строка
//      * Значение - ПеречислениеСсылка.ТипыДенежныхСредств
Функция ПолучитьТипыДенежныхСредств() Экспорт
    Возврат РаботаСДокументами.ПолучитьТипыДенежныхСредств();
КонецФункции

// Возвращаемое значение:
//	- Структура из КлючИЗначение
//      * Ключ - Строка
//      * Значение - ПеречислениеСсылка.ВидыОперацийПоступленияДенег
Функция ПолучитьВидыОперацийПоступленияДенег() Экспорт
    Возврат РаботаСДокументами.ПолучитьВидыОперацийПоступленияДенег();
КонецФункции

// Возвращаемое значение:
//	- ПеречислениеСсылка.ПризнакиОплаты, Неопределено
Функция ПолучитьПризнакиОплаты() Экспорт
    Возврат РаботаСМетаданными.ПолучитьЗначенияПеречисления(Тип("ПеречислениеСсылка.ПризнакиОплаты"));
КонецФункции

// Возвращаемое значение:
//	- СправочникСсылка.Кассы, Неопределено
Функция ПолучитьКассуПоУмолчанию() Экспорт
    Возврат Справочники.Кассы.ПолучитьОсновнуюКассу();
КонецФункции

// Параметры:
//	видОперации - ПеречислениеСсылка.ВидыОперацийПоступленияДенег
//  типДенежныхСредств - ПеречислениеСсылка.ТипыДенежныхСредств
//  значенияПолей - Структура, ФиксированнаяСтруктура
//      * Плательщик - СправочникСсылка.Контрагенты, СправочникСсылка.Сотрудники, СправочникСсылка.Банки, Неопределено
//      * Касса - СправочникСсылка.Кассы, Неопределено
//      * ЭквайринговыйТерминал - СправочникСсылка.ЭквайринговыеТерминалы, Неопределено
//      * РасчетныйСчет - СправочникСсылка.БанковскиеСчета, Неопределено
// Возвращаемое значение:
//	- Структура
//      * СчетДебета - ПланСчетовСсылка.Хозрасчетный
//      * СубконтоДебет - СправочникСсылка.Кассы, СправочникСсылка.ЭквайринговыеТерминалы, Неопределено
//      * СчетКредита - ПланСчетовСсылка.Хозрасчетный, Неопределено
//      * СубконтоКредит - СправочникСсылка.Контрагенты, СправочникСсылка.Сотрудники, СправочникСсылка.Банки, СправочникСсылка.БанковскиеСчета, Неопределено
//      * СодержаниеОперации - Строка, Неопределено
Функция ПолучитьАналитикуПроводки(Знач видОперации, Знач типДенежныхСредств, Знач значенияПолей) Экспорт
    структураАналитики = Новый Структура;
    структураАналитики.Вставить("СчетДебета", ПланыСчетов.Хозрасчетный.Касса);
    структураАналитики.Вставить("СубконтоДебет", значенияПолей.Касса);
    структураАналитики.Вставить("СчетКредита", Неопределено);
    структураАналитики.Вставить("СубконтоКредит", Неопределено);
    структураАналитики.Вставить("СодержаниеОперации", Неопределено);

    Если видОперации = Перечисления.ВидыОперацийПоступленияДенег.ОплатаОтПокупателя Тогда
        Если типДенежныхСредств = Перечисления.ТипыДенежныхСредств.Безналичные Тогда
            структураАналитики.СчетДебета = ПланыСчетов.Хозрасчетный.ПереводыВПути;
            структураАналитики.СубконтоДебет = значенияПолей.ЭквайринговыйТерминал;
        КонецЕсли;
        структураАналитики.СчетКредита = ПланыСчетов.Хозрасчетный.РасчетыСПокупателями;
        структураАналитики.СубконтоКредит = значенияПолей.Плательщик;
        структураАналитики.СодержаниеОперации = СтрШаблон("Оплата от покупателя %1",
                ?(видОперации = Перечисления.ВидыОперацийПоступленияДенег.ОплатаОтПокупателя, "банковской картой", "наличными в кассу"));

    ИначеЕсли видОперации = Перечисления.ВидыОперацийПоступленияДенег.ВозвратОтПоставщика Тогда
        структураАналитики.СчетКредита = ПланыСчетов.Хозрасчетный.РасчетыСПоставщиками;
        структураАналитики.СубконтоКредит = значенияПолей.Плательщик;
        структураАналитики.СодержаниеОперации = "Возврат от поставщика наличными в кассу";

    ИначеЕсли видОперации = Перечисления.ВидыОперацийПоступленияДенег.ПолучениеНаличныхВБанке Тогда
        структураАналитики.СчетКредита = ПланыСчетов.Хозрасчетный.РасчетныеСчета;
        структураАналитики.СубконтоКредит = значенияПолей.РасчетныйСчет;
        структураАналитики.СодержаниеОперации = "Получение наличных денег с расчетного счета в кассу";

    ИначеЕсли видОперации = Перечисления.ВидыОперацийПоступленияДенег.ВозвратОтПодотчетника Тогда
        структураАналитики.СчетКредита = ПланыСчетов.Хозрасчетный.РасчетыСПодотчетнымиЛицами;
        структураАналитики.СодержаниеОперации = "Возврат подотчетных средств";
        структураАналитики.СубконтоКредит = значенияПолей.Плательщик;

    Иначе
        ВызватьИсключение "Недопустимый вид операции.";
    КонецЕсли;

    Возврат структураАналитики;
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс
