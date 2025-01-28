CREATE PROCEDURE dbo.CheckOrderCredit
    @CustomerID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    BEGIN TRY
        DECLARE @CreditLimit DECIMAL(18, 2);
        DECLARE @ProductPrice DECIMAL(18, 2);
        DECLARE @OrderCost DECIMAL(18, 2);

        SELECT @CreditLimit = CreditLimit
        FROM dbo.CustomerTBL
        WHERE CustomerID = @CustomerID;

        IF @CreditLimit IS NULL
        BEGIN
            THROW 50001, FORMATMESSAGE('CustomerID %d not found.', @CustomerID), 1;
        END

        SELECT @ProductPrice = ProductPrice
        FROM dbo.ProductTBL
        WHERE ProductID = @ProductID;

        IF @ProductPrice IS NULL
        BEGIN
            THROW 50002, FORMATMESSAGE('ProductID %d not found.', @ProductID), 1;
        END
      
        SET @OrderCost = @ProductPrice * @Quantity;

        IF @OrderCost <= @CreditLimit
        BEGIN
            SELECT 
                'Yes you have enough credit' AS OrderStatus,
                @OrderCost AS OrderCost,
                @CreditLimit - @OrderCost AS RemainingCredit;
        END
        ELSE
        BEGIN
            SELECT 
                'You do not have enough credit' AS OrderStatus,
                @OrderCost AS OrderCost,
                @CreditLimit AS CreditLimit;
        END
    END TRY
    BEGIN CATCH
        -- Used the new info about ;throw for errors
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END
GO
